-- Location: supabase/migrations/20250827045812_bikeshare_complete_platform.sql
-- Schema Analysis: Fresh project - no existing schema
-- Integration Type: Complete bike-sharing platform
-- Dependencies: None (new schema)

-- 1. Types and Enums
CREATE TYPE public.user_role AS ENUM ('rider', 'host', 'admin');
CREATE TYPE public.bike_status AS ENUM ('available', 'rented', 'maintenance', 'inactive');
CREATE TYPE public.bike_type AS ENUM ('city', 'mountain', 'electric', 'hybrid', 'road');
CREATE TYPE public.rental_status AS ENUM ('active', 'completed', 'cancelled');
CREATE TYPE public.listing_status AS ENUM ('pending', 'approved', 'rejected', 'inactive');

-- 2. Core Tables
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id),
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    phone TEXT,
    role public.user_role DEFAULT 'rider'::public.user_role,
    profile_image_url TEXT,
    rating DECIMAL(3,2) DEFAULT 0.00,
    total_reviews INTEGER DEFAULT 0,
    is_host BOOLEAN DEFAULT false,
    is_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    icon_url TEXT,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.bike_listings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    host_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
    bike_type public.bike_type NOT NULL,
    price_per_hour DECIMAL(10,2) NOT NULL,
    price_per_day DECIMAL(10,2),
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    address TEXT NOT NULL,
    city TEXT NOT NULL,
    country TEXT NOT NULL,
    status public.listing_status DEFAULT 'pending'::public.listing_status,
    bike_status public.bike_status DEFAULT 'available'::public.bike_status,
    is_available BOOLEAN DEFAULT true,
    minimum_rental_hours INTEGER DEFAULT 1,
    maximum_rental_hours INTEGER DEFAULT 24,
    features JSONB DEFAULT '[]'::jsonb,
    rules TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.bike_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bike_id UUID REFERENCES public.bike_listings(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    is_primary BOOLEAN DEFAULT false,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.rentals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    renter_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    bike_id UUID REFERENCES public.bike_listings(id) ON DELETE CASCADE,
    host_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    actual_start_time TIMESTAMPTZ,
    actual_end_time TIMESTAMPTZ,
    total_hours INTEGER NOT NULL,
    hourly_rate DECIMAL(10,2) NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    status public.rental_status DEFAULT 'active'::public.rental_status,
    pickup_code TEXT,
    return_code TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rental_id UUID REFERENCES public.rentals(id) ON DELETE CASCADE,
    reviewer_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    reviewee_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    bike_id UUID REFERENCES public.bike_listings(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    is_bike_review BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Essential Indexes
CREATE INDEX idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX idx_user_profiles_role ON public.user_profiles(role);
CREATE INDEX idx_bike_listings_host_id ON public.bike_listings(host_id);
CREATE INDEX idx_bike_listings_category_id ON public.bike_listings(category_id);
CREATE INDEX idx_bike_listings_location ON public.bike_listings(latitude, longitude);
CREATE INDEX idx_bike_listings_status ON public.bike_listings(status);
CREATE INDEX idx_bike_listings_is_available ON public.bike_listings(is_available);
CREATE INDEX idx_bike_images_bike_id ON public.bike_images(bike_id);
CREATE INDEX idx_rentals_renter_id ON public.rentals(renter_id);
CREATE INDEX idx_rentals_bike_id ON public.rentals(bike_id);
CREATE INDEX idx_rentals_status ON public.rentals(status);
CREATE INDEX idx_reviews_rental_id ON public.reviews(rental_id);
CREATE INDEX idx_reviews_bike_id ON public.reviews(bike_id);

-- 4. Storage Buckets
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES 
    ('bike-images', 'bike-images', true, 10485760, ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/jpg']),
    ('profile-images', 'profile-images', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/jpg']);

-- 5. Functions (MUST BE BEFORE RLS POLICIES)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO public.user_profiles (id, email, full_name, role)
    VALUES (
        NEW.id, 
        NEW.email, 
        COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
        COALESCE(NEW.raw_user_meta_data->>'role', 'rider')::public.user_role
    );
    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.update_bike_listing_updated_at()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.update_user_rating()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Update reviewee rating when new review is added
    UPDATE public.user_profiles 
    SET 
        rating = (
            SELECT ROUND(AVG(rating)::numeric, 2) 
            FROM public.reviews 
            WHERE reviewee_id = NEW.reviewee_id
        ),
        total_reviews = (
            SELECT COUNT(*) 
            FROM public.reviews 
            WHERE reviewee_id = NEW.reviewee_id
        )
    WHERE id = NEW.reviewee_id;
    
    RETURN NEW;
END;
$$;

-- 6. Triggers
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

CREATE TRIGGER update_bike_listings_updated_at
    BEFORE UPDATE ON public.bike_listings
    FOR EACH ROW EXECUTE FUNCTION public.update_bike_listing_updated_at();

CREATE TRIGGER update_user_rating_trigger
    AFTER INSERT ON public.reviews
    FOR EACH ROW EXECUTE FUNCTION public.update_user_rating();

-- 7. Enable RLS
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bike_listings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bike_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rentals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

-- 8. RLS Policies
-- Pattern 1: Core user table - Simple direct comparison
CREATE POLICY "users_manage_own_user_profiles"
ON public.user_profiles
FOR ALL
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Pattern 4: Public read, private write for categories
CREATE POLICY "public_can_read_categories"
ON public.categories
FOR SELECT
TO public
USING (true);

CREATE POLICY "admins_manage_categories"
ON public.categories
FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM auth.users au
        WHERE au.id = auth.uid() 
        AND au.raw_user_meta_data->>'role' = 'admin'
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM auth.users au
        WHERE au.id = auth.uid() 
        AND au.raw_user_meta_data->>'role' = 'admin'
    )
);

-- Pattern 4: Public read for bike listings
CREATE POLICY "public_can_read_bike_listings"
ON public.bike_listings
FOR SELECT
TO public
USING (status = 'approved' AND is_available = true);

-- Pattern 2: Simple user ownership for bike listings management
CREATE POLICY "hosts_manage_own_bike_listings"
ON public.bike_listings
FOR ALL
TO authenticated
USING (host_id = auth.uid())
WITH CHECK (host_id = auth.uid());

-- Pattern 2: Simple ownership for bike images
CREATE POLICY "hosts_manage_bike_images"
ON public.bike_images
FOR ALL
TO authenticated
USING (
    bike_id IN (
        SELECT id FROM public.bike_listings 
        WHERE host_id = auth.uid()
    )
)
WITH CHECK (
    bike_id IN (
        SELECT id FROM public.bike_listings 
        WHERE host_id = auth.uid()
    )
);

-- Rental policies - renters and hosts can see their rentals
CREATE POLICY "users_view_own_rentals"
ON public.rentals
FOR SELECT
TO authenticated
USING (renter_id = auth.uid() OR host_id = auth.uid());

CREATE POLICY "renters_create_rentals"
ON public.rentals
FOR INSERT
TO authenticated
WITH CHECK (renter_id = auth.uid());

CREATE POLICY "participants_update_rentals"
ON public.rentals
FOR UPDATE
TO authenticated
USING (renter_id = auth.uid() OR host_id = auth.uid())
WITH CHECK (renter_id = auth.uid() OR host_id = auth.uid());

-- Review policies
CREATE POLICY "public_can_read_reviews"
ON public.reviews
FOR SELECT
TO public
USING (true);

CREATE POLICY "users_create_reviews"
ON public.reviews
FOR INSERT
TO authenticated
WITH CHECK (reviewer_id = auth.uid());

CREATE POLICY "reviewers_manage_own_reviews"
ON public.reviews
FOR ALL
TO authenticated
USING (reviewer_id = auth.uid())
WITH CHECK (reviewer_id = auth.uid());

-- Storage policies for bike images
CREATE POLICY "public_can_view_bike_images"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'bike-images');

CREATE POLICY "authenticated_users_upload_bike_images"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'bike-images');

CREATE POLICY "owners_manage_bike_images_storage"
ON storage.objects
FOR UPDATE, DELETE
TO authenticated
USING (bucket_id = 'bike-images' AND owner = auth.uid());

-- Storage policies for profile images
CREATE POLICY "public_can_view_profile_images"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'profile-images');

CREATE POLICY "users_manage_own_profile_images"
ON storage.objects
FOR ALL
TO authenticated
USING (
    bucket_id = 'profile-images' 
    AND owner = auth.uid()
)
WITH CHECK (
    bucket_id = 'profile-images' 
    AND owner = auth.uid()
);

-- 9. Mock Data
DO $$
DECLARE
    rider_id UUID := gen_random_uuid();
    host_id UUID := gen_random_uuid();
    admin_id UUID := gen_random_uuid();
    category1_id UUID := gen_random_uuid();
    category2_id UUID := gen_random_uuid();
    bike1_id UUID := gen_random_uuid();
    bike2_id UUID := gen_random_uuid();
    rental1_id UUID := gen_random_uuid();
BEGIN
    -- Create complete auth.users records
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        (rider_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'rider@example.com', crypt('password123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "João Silva", "role": "rider"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (host_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'host@example.com', crypt('password123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Maria Santos", "role": "host"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (admin_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'admin@example.com', crypt('password123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Admin User", "role": "admin"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null);

    -- Update user profiles with additional data
    UPDATE public.user_profiles 
    SET 
        phone = '+55 11 99999-0001',
        is_verified = true,
        profile_image_url = 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face'
    WHERE id = rider_id;

    UPDATE public.user_profiles 
    SET 
        phone = '+55 11 99999-0002',
        is_host = true,
        is_verified = true,
        rating = 4.8,
        total_reviews = 23,
        profile_image_url = 'https://images.unsplash.com/photo-1494790108755-2616b612b6c5?w=150&h=150&fit=crop&crop=face'
    WHERE id = host_id;

    UPDATE public.user_profiles 
    SET 
        phone = '+55 11 99999-0000',
        is_verified = true,
        role = 'admin'::public.user_role,
        profile_image_url = 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face'
    WHERE id = admin_id;

    -- Create categories
    INSERT INTO public.categories (id, name, icon_url, description) VALUES
        (category1_id, 'City Bikes', 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=100&h=100', 'Perfect for urban commuting and city rides'),
        (category2_id, 'Electric Bikes', 'https://images.unsplash.com/photo-1544191696-15ca02b7c639?w=100&h=100', 'Eco-friendly electric bikes for effortless riding'),
        (gen_random_uuid(), 'Mountain Bikes', 'https://images.unsplash.com/photo-1558618047-3c8c76ca7e28?w=100&h=100', 'Adventure-ready bikes for trails and mountains'),
        (gen_random_uuid(), 'Road Bikes', 'https://images.unsplash.com/photo-1558618047-3c8c76ca7e28?w=100&h=100', 'Speed-focused bikes for long distance rides');

    -- Create bike listings
    INSERT INTO public.bike_listings (
        id, host_id, title, description, category_id, bike_type,
        price_per_hour, price_per_day, latitude, longitude, address, city, country,
        status, features
    ) VALUES
        (bike1_id, host_id, 'Modern City Bike - Copacabana', 
         'Beautiful city bike perfect for exploring Rio de Janeiro. Well-maintained with comfortable seat and smooth ride.',
         category1_id, 'city', 15.00, 80.00, -22.9711, -43.1822,
         'Copacabana Beach, Rio de Janeiro', 'Rio de Janeiro', 'Brazil',
         'approved', '["helmet included", "lock included", "lights", "basket"]'::jsonb),
        (bike2_id, host_id, 'Electric Bike - Ipanema',
         'Premium electric bike with long battery life. Perfect for beach rides and city exploration.',
         category2_id, 'electric', 25.00, 150.00, -22.9836, -43.1976,
         'Ipanema Beach, Rio de Janeiro', 'Rio de Janeiro', 'Brazil',
         'approved', '["helmet included", "lock included", "GPS tracker", "USB charger"]'::jsonb),
        (gen_random_uuid(), host_id, 'Mountain Bike Adventure',
         'Rugged mountain bike ready for Tijuca trails. Full suspension and professional grade components.',
         category1_id, 'mountain', 20.00, 120.00, -22.9246, -43.2451,
         'Tijuca Forest, Rio de Janeiro', 'Rio de Janeiro', 'Brazil',
         'approved', '["helmet included", "repair kit", "water bottle holder"]'::jsonb);

    -- Create bike images
    INSERT INTO public.bike_images (bike_id, image_url, is_primary, display_order) VALUES
        (bike1_id, 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&h=600', true, 1),
        (bike1_id, 'https://images.unsplash.com/photo-1544191696-15ca02b7c639?w=800&h=600', false, 2),
        (bike1_id, 'https://images.unsplash.com/photo-1502744688674-c619d1586c9e?w=800&h=600', false, 3),
        (bike2_id, 'https://images.unsplash.com/photo-1571068316344-75bc76f77890?w=800&h=600', true, 1),
        (bike2_id, 'https://images.unsplash.com/photo-1544191696-15ca02b7c639?w=800&h=600', false, 2);

    -- Create sample rental
    INSERT INTO public.rentals (
        id, renter_id, bike_id, host_id, start_time, end_time,
        total_hours, hourly_rate, total_amount, status, pickup_code, return_code
    ) VALUES
        (rental1_id, rider_id, bike1_id, host_id, 
         CURRENT_TIMESTAMP - INTERVAL '2 days', CURRENT_TIMESTAMP - INTERVAL '1 day',
         4, 15.00, 60.00, 'completed', 'PICK123', 'RET456');

    -- Create sample reviews
    INSERT INTO public.reviews (rental_id, reviewer_id, reviewee_id, bike_id, rating, comment) VALUES
        (rental1_id, rider_id, host_id, bike1_id, 5, 
         'Excellent bike and very friendly host! The bike was clean, well-maintained and perfect for exploring Copacabana. Highly recommend!'),
        (rental1_id, host_id, rider_id, bike1_id, 5,
         'Great renter! Very respectful with the bike and returned it on time. Would rent to João again anytime!');

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error in mock data insertion: %', SQLERRM;
END $$;