import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../models/user_profile.dart';
import '../../routes/app_routes.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  UserProfile? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await _authService.getCurrentUserProfile();
      setState(() {
        _userProfile = profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar perfil: $e')),
        );
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.loginScreen,
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao sair: $e')),
        );
      }
    }
  }

  Future<void> _enableHostMode() async {
    try {
      await _authService.enableHostMode();
      await _loadUserProfile(); // Reload profile
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Modo anfitrião ativado com sucesso!')),
        );
        Navigator.pushNamed(context, AppRoutes.bikeListing);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao ativar modo anfitrião: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Configurações',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Profile Section
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Profile Image
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: _userProfile?.profileImageUrl != null
                              ? NetworkImage(_userProfile!.displayImageUrl)
                              : null,
                          backgroundColor: Colors.grey[200],
                          child: _userProfile?.profileImageUrl == null
                              ? Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.grey[400],
                                )
                              : null,
                        ),
                        const SizedBox(height: 16),

                        // Name
                        Text(
                          _userProfile?.fullName ?? 'Usuário',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Email
                        Text(
                          _userProfile?.email ?? '',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Role badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _userProfile?.isHost == true
                                ? Colors.green[100]
                                : Colors.blue[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _userProfile?.isHost == true
                                    ? Icons.business
                                    : Icons.person,
                                size: 16,
                                color: _userProfile?.isHost == true
                                    ? Colors.green[700]
                                    : Colors.blue[700],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _userProfile?.isHost == true
                                    ? 'Anfitrião'
                                    : 'Usuário',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: _userProfile?.isHost == true
                                      ? Colors.green[700]
                                      : Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Menu Items
                  Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        // Host Mode / My Bikes
                        if (_userProfile?.isHost == true)
                          _buildMenuItem(
                            icon: Icons.directions_bike,
                            title: 'Minhas Bicicletas',
                            subtitle: 'Gerenciar suas bicicletas anunciadas',
                            onTap: () => Navigator.pushNamed(
                                context, AppRoutes.myBikesScreen),
                          )
                        else
                          _buildMenuItem(
                            icon: Icons.business,
                            title: 'Anunciar sua Bicicleta',
                            subtitle: 'Torne-se um anfitrião e ganhe dinheiro',
                            onTap: _showHostModeDialog,
                            trailing:
                                const Icon(Icons.arrow_forward_ios, size: 16),
                          ),

                        _buildDivider(),

                        // Profile
                        _buildMenuItem(
                          icon: Icons.person_outline,
                          title: 'Perfil',
                          subtitle: 'Editar informações pessoais',
                          onTap: () => Navigator.pushNamed(
                              context, AppRoutes.profileScreen),
                        ),

                        _buildDivider(),

                        // My Rentals
                        _buildMenuItem(
                          icon: Icons.history,
                          title: 'Meus Aluguéis',
                          subtitle: 'Histórico de aluguéis realizados',
                          onTap: () => Navigator.pushNamed(
                              context, AppRoutes.myRentalsScreen),
                        ),

                        _buildDivider(),

                        // Favorites
                        _buildMenuItem(
                          icon: Icons.favorite_outline,
                          title: 'Favoritos',
                          subtitle: 'Bicicletas salvas como favoritas',
                          onTap: () => Navigator.pushNamed(
                              context, AppRoutes.favoritesScreen),
                        ),

                        _buildDivider(),

                        // Support
                        _buildMenuItem(
                          icon: Icons.help_outline,
                          title: 'Suporte',
                          subtitle: 'Central de ajuda e contato',
                          onTap: () => Navigator.pushNamed(
                              context, AppRoutes.supportScreen),
                        ),

                        _buildDivider(),

                        // Privacy
                        _buildMenuItem(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Privacidade',
                          subtitle: 'Política de privacidade e termos',
                          onTap: () => Navigator.pushNamed(
                              context, AppRoutes.privacyScreen),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Sign Out
                  Container(
                    color: Colors.white,
                    child: _buildMenuItem(
                      icon: Icons.logout,
                      title: 'Sair',
                      subtitle: 'Desconectar da sua conta',
                      onTap: _showSignOutDialog,
                      iconColor: Colors.red,
                      textColor: Colors.red,
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
    Color? iconColor,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (iconColor ?? Colors.grey[600])?.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor ?? Colors.grey[600],
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textColor ?? Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            trailing ??
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: Colors.grey[100],
      margin: const EdgeInsets.only(left: 76),
    );
  }

  void _showHostModeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.business,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              const Text('Anunciar Bicicleta'),
            ],
          ),
          content: const Text(
            'Quer ganhar dinheiro alugando sua bicicleta? '
            'Torne-se um anfitrião e conecte-se com ciclistas da sua região!',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _enableHostMode();
              },
              child: const Text('Continuar'),
            ),
          ],
        );
      },
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Sair da Conta'),
          content: const Text('Tem certeza que deseja sair da sua conta?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );
  }
}
