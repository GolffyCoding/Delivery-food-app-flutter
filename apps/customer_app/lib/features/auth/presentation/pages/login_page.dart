import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_design_system/opendelivery_design_system.dart';
import 'package:opendelivery_shared_widgets/opendelivery_shared_widgets.dart';
import 'package:customer_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:customer_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:customer_app/features/auth/presentation/bloc/login_bloc.dart';
import 'package:customer_app/di/injection.dart';
import 'package:customer_app/features/auth/presentation/pages/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  static const String route = '/login';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<LoginBloc>().add(LoginWithEmail(_emailController.text.trim(), _passwordController.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LoginBloc>(),
      child: Builder(builder: (context) {
        return BlocListener<LoginBloc, LoginState>(
          listener: (context, state) {
            if (state is LoginSuccess) {
              context.read<AuthBloc>().add(AuthLoginSuccess(state.result));
            } else if (state is LoginError) {
              context.showSnackBar(state.failure.message, isError: true);
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
                        Text('Welcome Back', style: context.textTheme.headlineLarge),
                        const SizedBox(height: AppSpacing.sm),
                        Text('Sign in to continue ordering', style: context.textTheme.bodyLarge?.copyWith(color: context.colorScheme.outline)),
                        const SizedBox(height: 40),
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
                          hint: 'Enter your password',
                          controller: _passwordController,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          prefixIcon: const Icon(Icons.lock_outlined),
                          validator: Validators.password,
                          onSubmitted: (_) => _onLogin(context),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: AppTextButton(text: 'Forgot Password?', fontWeight: FontWeight.w500, onPressed: () {}),
                        ),
                        const SizedBox(height: 24),
                        BlocBuilder<LoginBloc, LoginState>(
                          builder: (context, state) {
                            return AppButton(text: 'Sign In', onPressed: () => _onLogin(context), isLoading: state is LoginLoading);
                          },
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Don't have an account?", style: context.textTheme.bodyMedium),
                            AppTextButton(text: ' Sign Up', onPressed: () => context.push(RegisterPage.route)),
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
