import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_design_system/opendelivery_design_system.dart';
import 'package:opendelivery_shared_widgets/opendelivery_shared_widgets.dart';
import 'package:merchant_app/di/injection.dart';
import 'package:merchant_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:merchant_app/features/auth/presentation/bloc/auth_form_bloc.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  static const String route = '/auth';

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoginMode = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final bloc = context.read<AuthFormBloc>();
    if (_isLoginMode) {
      bloc.add(SubmitLogin(_emailController.text.trim(), _passwordController.text));
    } else {
      bloc.add(SubmitRegister(
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthFormBloc>(),
      child: Builder(builder: (context) {
        return BlocListener<AuthFormBloc, AuthFormState>(
          listener: (context, state) {
            if (state is AuthFormSuccess) {
              context.read<AuthBloc>().add(AuthLoginSuccess(state.result));
            } else if (state is AuthFormError) {
              context.showSnackBar(state.message, isError: true);
            }
          },
          child: Scaffold(
            body: SafeArea(
              child: Padding(
                padding: AppSpacing.screenPadding,
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 40),
                        Icon(Icons.storefront_rounded, size: 64, color: context.colorScheme.primary),
                        const SizedBox(height: AppSpacing.lg),
                        Text(_isLoginMode ? 'Merchant Sign In' : 'Register Your Restaurant', style: context.textTheme.headlineMedium),
                        const SizedBox(height: 32),
                        if (!_isLoginMode) ...[
                          Row(
                            children: [
                              Expanded(child: AppTextField(label: 'First Name', controller: _firstNameController, validator: Validators.name)),
                              const SizedBox(width: AppSpacing.lg),
                              Expanded(child: AppTextField(label: 'Last Name', controller: _lastNameController, validator: Validators.name)),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                        AppTextField(
                          label: 'Email',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.email,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(label: 'Password', controller: _passwordController, obscureText: true, validator: Validators.password),
                        const SizedBox(height: 32),
                        BlocBuilder<AuthFormBloc, AuthFormState>(
                          builder: (context, state) {
                            return AppButton(
                              text: _isLoginMode ? 'Sign In' : 'Create Account',
                              isLoading: state is AuthFormLoading,
                              onPressed: () => _submit(context),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        AppTextButton(
                          text: _isLoginMode ? "Don't have an account? Sign Up" : 'Already have an account? Sign In',
                          onPressed: () => setState(() => _isLoginMode = !_isLoginMode),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
