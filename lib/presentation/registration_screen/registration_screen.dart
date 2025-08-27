import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/custom_text_field_widget.dart';
import './widgets/password_strength_indicator_widget.dart';
import './widgets/terms_acceptance_widget.dart';
import './widgets/user_type_selector_widget.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Form state
  String _selectedUserType = 'renter';
  bool _termsAccepted = false;
  bool _isLoading = false;
  bool _showSuccess = false;

  // Validation state
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _addListeners();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addListeners() {
    _nameController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
    _phoneController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);
  }

  void _validateForm() {
    final isValid = _nameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _isValidEmail(_emailController.text) &&
        _phoneController.text.isNotEmpty &&
        _isValidPhone(_phoneController.text) &&
        _passwordController.text.isNotEmpty &&
        _isValidPassword(_passwordController.text) &&
        _confirmPasswordController.text == _passwordController.text &&
        _termsAccepted;

    if (_isFormValid != isValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    return cleanPhone.length == 11;
  }

  bool _isValidPassword(String password) {
    return password.length >= 8 &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[a-z]')) &&
        password.contains(RegExp(r'[0-9]'));
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nome é obrigatório';
    }
    if (value.length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email é obrigatório';
    }
    if (!_isValidEmail(value)) {
      return 'Digite um email válido';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefone é obrigatório';
    }
    if (!_isValidPhone(value)) {
      return 'Digite um telefone válido (11 dígitos)';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }
    if (!_isValidPassword(value)) {
      return 'Senha deve ter 8+ caracteres, maiúscula, minúscula e número';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirmação de senha é obrigatória';
    }
    if (value != _passwordController.text) {
      return 'Senhas não coincidem';
    }
    return null;
  }

  Future<void> _handleRegistration() async {
    if (!_isFormValid) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call
      await Future.delayed(Duration(seconds: 2));

      // Check for duplicate email (mock validation)
      if (_emailController.text.toLowerCase() == 'admin@bikeshare.com') {
        _showErrorDialog('Este email já está em uso. Tente outro email.');
        return;
      }

      // Success
      setState(() {
        _showSuccess = true;
      });

      // Navigate to onboarding after showing success
      await Future.delayed(Duration(seconds: 2));
      Navigator.pushReplacementNamed(context, '/onboarding-flow');
    } catch (e) {
      _showErrorDialog(
          'Erro ao criar conta. Verifique sua conexão e tente novamente.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Erro'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: _showSuccess ? _buildSuccessView() : _buildRegistrationForm(),
      ),
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                color: AppTheme.getSuccessColor(true),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'check',
                color: Colors.white,
                size: 10.w,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Conta criada com sucesso!',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                color: AppTheme.getSuccessColor(true),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Text(
              'Bem-vindo ao BikeShare P2P! Você será redirecionado em instantes.',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationForm() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.all(6.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPersonalInfoSection(),
                  SizedBox(height: 4.h),
                  _buildPasswordSection(),
                  SizedBox(height: 4.h),
                  _buildUserTypeSection(),
                  SizedBox(height: 4.h),
                  _buildTermsSection(),
                  SizedBox(height: 6.h),
                  _buildRegisterButton(),
                  SizedBox(height: 4.h),
                  _buildLoginLink(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.0),
          bottomRight: Radius.circular(24.0),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: CustomIconWidget(
                  iconName: 'arrow_back',
                  color: Colors.white,
                  size: 24,
                ),
              ),
              Expanded(
                child: Text(
                  'Criar Conta',
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(width: 12.w),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            'Junte-se à comunidade BikeShare P2P',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informações Pessoais',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 3.h),
        CustomTextFieldWidget(
          label: 'Nome Completo',
          hintText: 'Digite seu nome completo',
          controller: _nameController,
          validator: _validateName,
          showValidationIcon: true,
          onChanged: _validateForm,
        ),
        SizedBox(height: 3.h),
        CustomTextFieldWidget(
          label: 'Email',
          hintText: 'Digite seu email',
          controller: _emailController,
          validator: _validateEmail,
          keyboardType: TextInputType.emailAddress,
          showValidationIcon: true,
          onChanged: _validateForm,
        ),
        SizedBox(height: 3.h),
        CustomTextFieldWidget(
          label: 'Telefone',
          hintText: '(11) 99999-9999',
          controller: _phoneController,
          validator: _validatePhone,
          keyboardType: TextInputType.phone,
          showValidationIcon: true,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            TextInputFormatter.withFunction((oldValue, newValue) {
              final text = newValue.text;
              if (text.length <= 11) {
                String formatted = text;
                if (text.length >= 3) {
                  formatted = '(${text.substring(0, 2)}) ${text.substring(2)}';
                }
                if (text.length >= 8) {
                  formatted =
                      '(${text.substring(0, 2)}) ${text.substring(2, 7)}-${text.substring(7)}';
                }
                return TextEditingValue(
                  text: formatted,
                  selection: TextSelection.collapsed(offset: formatted.length),
                );
              }
              return oldValue;
            }),
          ],
          onChanged: _validateForm,
        ),
      ],
    );
  }

  Widget _buildPasswordSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Segurança',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 3.h),
        CustomTextFieldWidget(
          label: 'Senha',
          hintText: 'Digite sua senha',
          controller: _passwordController,
          validator: _validatePassword,
          obscureText: true,
          showVisibilityToggle: true,
          onChanged: _validateForm,
        ),
        PasswordStrengthIndicatorWidget(
          password: _passwordController.text,
        ),
        SizedBox(height: 3.h),
        CustomTextFieldWidget(
          label: 'Confirmar Senha',
          hintText: 'Digite sua senha novamente',
          controller: _confirmPasswordController,
          validator: _validateConfirmPassword,
          obscureText: true,
          showVisibilityToggle: true,
          showValidationIcon: true,
          onChanged: _validateForm,
        ),
      ],
    );
  }

  Widget _buildUserTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Perfil de Usuário',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 3.h),
        UserTypeSelectorWidget(
          selectedType: _selectedUserType,
          onTypeChanged: (type) {
            setState(() {
              _selectedUserType = type;
            });
            _validateForm();
          },
        ),
        SizedBox(height: 2.h),
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'info',
                color: AppTheme.lightTheme.primaryColor,
                size: 20,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  _selectedUserType == 'renter'
                      ? 'Como locatário, você poderá alugar bicicletas de outros usuários.'
                      : 'Como proprietário, você poderá disponibilizar suas bicicletas para aluguel.',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTermsSection() {
    return TermsAcceptanceWidget(
      isAccepted: _termsAccepted,
      onChanged: (value) {
        setState(() {
          _termsAccepted = value ?? false;
        });
        _validateForm();
      },
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 6.h,
      child: ElevatedButton(
        onPressed: _isFormValid && !_isLoading ? _handleRegistration : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isFormValid
              ? AppTheme.lightTheme.primaryColor
              : AppTheme.lightTheme.colorScheme.outline,
          foregroundColor: Colors.white,
        ),
        child: _isLoading
            ? SizedBox(
                width: 5.w,
                height: 5.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Cadastrar',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: GestureDetector(
        onTap: () => Navigator.pushReplacementNamed(context, '/login-screen'),
        child: RichText(
          text: TextSpan(
            style: AppTheme.lightTheme.textTheme.bodyMedium,
            children: [
              TextSpan(
                text: 'Já tem uma conta? ',
                style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
              TextSpan(
                text: 'Fazer Login',
                style: TextStyle(
                  color: AppTheme.lightTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
