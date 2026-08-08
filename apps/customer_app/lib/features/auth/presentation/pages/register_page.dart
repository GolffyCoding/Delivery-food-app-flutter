import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_design_system/opendelivery_design_system.dart';
import 'package:opendelivery_shared_widgets/opendelivery_shared_widgets.dart';
import 'package:customer_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:customer_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:customer_app/features/auth/presentation/bloc/register_bloc.dart';
import 'package:customer_app/di/injection.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  static const String route = '/register';

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegister(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<RegisterBloc>().add(
            RegisterSubmit(
              _firstNameController.text.trim(),
              _lastNameController.text.trim(),
              _emailController.text.trim(),
              _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RegisterBloc>(),
      child: Builder(builder: (context) {
        return BlocListener<RegisterBloc, RegisterState>(
          listener: (context, state) {
            if (state is RegisterSuccess) {
              context.read<AuthBloc>().add(AuthLoginSuccess(state.result));
            } else if (state is RegisterError) {
              context.showSnackBar(state.failure.message, isError: true);
            }
          },
          child: Scaffold(
            appBar: const AppAppBar(showBackButton: true),
            body: SafeArea(
              child: Padding(
                padding: AppSpacing.screenPadding,
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Create Account', style: context.textTheme.headlineLarge),
                        const SizedBox(height: AppSpacing.sm),
                        Text('Join us to start ordering delicious food', style: context.textTheme.bodyLarge?.copyWith(color: context.colorScheme.outline)),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                label: 'First Name',
                                hint: 'John',
                                controller: _firstNameController,
                                textInputAction: TextInputAction.next,
                                prefixIcon: const Icon(Icons.person_outlined),
                                validator: Validators.name,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            Expanded(
                              child: AppTextField(
                                label: 'Last Name',
                                hint: 'Doe',
                                controller: _lastNameController,
                                textInputAction: TextInputAction.next,
                                validator: Validators.name,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          label: 'Email',
                          hint: 'you@example.com',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          prefixIcon: const Icon(Icons.email_outlined),
                          validator: Validators.email,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          label: 'Password',
                          hint: 'Min 8 characters',
                          controller: _passwordController,
                          obscureText: true,
                          textInputAction: TextInputAction.next,
                          prefixIcon: const Icon(Icons.lock_outlined),
                          validator: Validators.password,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          label: 'Confirm Password',
                          hint: 'Re-enter password',
                          controller: _confirmPasswordController,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          prefixIcon: const Icon(Icons.lock_outlined),
                          validator: (value) => Validators.confirmPassword(value, _passwordController.text),
                          onSubmitted: (_) => _onRegister(context),
                        ),
                        const SizedBox(height: 32),
                        BlocBuilder<RegisterBloc, RegisterState>(
                          builder: (context, state) {
                            return AppButton(text: 'Create Account', onPressed: () => _onRegister(context), isLoading: state is RegisterLoading);
                          },
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Already have an account?', style: context.textTheme.bodyMedium),
                            AppTextButton(text: ' Sign In', onPressed: () => Navigator.of(context).pop()),
                          ],
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
