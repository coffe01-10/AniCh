import 'package:flutter/material.dart';
import 'package:xs/src/pages/account/controller.dart';
import 'package:xs/src/widgets/navbar.dart';
import 'package:xs/src/app/routes.dart';
import 'package:xs/src/widgets/controller_builder.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final emailKey = GlobalKey<FormState>();
    final codeKey = GlobalKey<FormState>();
    final nameKey = GlobalKey<FormState>();
    final passwordKey = GlobalKey<FormState>();
    final ValueNotifier<bool> getCodeStatus = ValueNotifier(false);
    final ValueNotifier<bool> emailExist = ValueNotifier(false);
    final ValueNotifier<bool> nameExist = ValueNotifier(false);
    return ControllerBuilder(
        create: () => RegisterController(),
        builder: (context, controller) {
          return Scaffold(
            extendBody: true,
            key: const PageStorageKey<String>('register'),
            appBar: AppBar(
                title: const Text('注册'),
                // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                automaticallyImplyLeading: false),
            body: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 300),
                margin:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Form(
                      key: emailKey,
                      child: Focus(
                        onFocusChange: (value) async {
                          if (!value) {
                            final v = emailKey.currentState!.validate();
                            if (v) {
                              final exist = await controller.checkEmail();
                              emailExist.value = (exist);
                              emailKey.currentState!.validate();
                            }
                          }
                        },
                        child: TextFormField(
                          initialValue: controller.email.value,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请输入邮箱地址';
                            }
                            if (!RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$')
                                .hasMatch(value)) {
                              return '邮箱地址格式错误';
                            }
                            if (emailExist.value) {
                              return '邮箱地址已存在';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            emailExist.value = (false);
                            controller.email.value = (value);
                            if (RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$')
                                .hasMatch(value)) {
                              getCodeStatus.value = (true);
                            } else {
                              getCodeStatus.value = (false);
                            }
                          },
                          decoration: InputDecoration(
                              labelText: '邮箱地址',
                              hintText: '请输入邮箱地址',
                              isCollapsed: false,
                              suffix: ListenableBuilder(
                                  listenable: getCodeStatus,
                                  builder: (context, _) => Visibility(
                                        visible: getCodeStatus.value,
                                        child: TextButton(
                                            onPressed: () async {
                                              getCodeStatus.value = (false);
                                              final isSuccess =
                                                  await controller.getCode();
                                              getCodeStatus.value = (true);
                                              if (isSuccess) {
                                                // ignore: use_build_context_synchronously
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                        const SnackBar(
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  margin: EdgeInsets.only(
                                                      bottom: 10,
                                                      left: 100,
                                                      right: 100),
                                                  content: Text('验证码获取成功'),
                                                ));
                                              } else {
                                                // ignore: use_build_context_synchronously
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                        const SnackBar(
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  margin: EdgeInsets.only(
                                                      bottom: 10,
                                                      left: 100,
                                                      right: 100),
                                                  content: Text('验证码获取失败，请重试'),
                                                ));
                                              }
                                            },
                                            style: ButtonStyle(
                                              padding: WidgetStateProperty.all(
                                                  const EdgeInsets.all(0)),
                                              overlayColor:
                                                  WidgetStateProperty.all(
                                                      Colors.transparent),
                                            ),
                                            child: const Text('获取验证码')),
                                      )),
                              contentPadding: const EdgeInsets.only(
                                  top: 0, bottom: 0, left: 0, right: 0)),
                        ),
                      ),
                    ),
                    ListenableBuilder(
                        listenable:
                            Listenable.merge([controller.code, getCodeStatus]),
                        builder: (context, _) => Visibility(
                              visible: getCodeStatus.value,
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Form(
                                    key: codeKey,
                                    child: Focus(
                                      onFocusChange: (value) {
                                        if (!value) {
                                          codeKey.currentState!.validate();
                                        }
                                      },
                                      child: TextFormField(
                                        initialValue: controller.code.value,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return '请输入验证码';
                                          }
                                          if (value.length != 6 ||
                                              int.tryParse(value) == null) {
                                            return '验证码格式错误';
                                          }
                                          return null;
                                        },
                                        onChanged: (value) {
                                          controller.code.value = (value);
                                        },
                                        decoration: const InputDecoration(
                                            labelText: '验证码',
                                            hintText: '请输入验证码',
                                            isCollapsed: false,
                                            contentPadding: EdgeInsets.only(
                                                top: 0,
                                                bottom: 0,
                                                left: 0,
                                                right: 0)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                    const SizedBox(
                      height: 10,
                    ),
                    Form(
                      key: nameKey,
                      child: Focus(
                        onFocusChange: (value) async {
                          if (!value) {
                            final v = nameKey.currentState!.validate();
                            if (v) {
                              final exist = await controller.checkName();
                              nameExist.value = (exist);
                              nameKey.currentState!.validate();
                            }
                          }
                        },
                        child: TextFormField(
                          initialValue: controller.name.value,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请输入用户名';
                            }
                            final pattern = RegExp(
                                r'^[\u2E80-\u2FDF\u3040-\u318F\u31A0-\u31BF\u31F0-\u31FF\u3400-\u4DB5\u4E00-\u9FFF\uA960-\uA97F\uAC00-\uD7FFA-Za-z0-9\、，。？！·\,\.\?\!\_\+\=\-]{2,30}$');
                            if (!pattern.hasMatch(value)) {
                              return '用户名格式错误';
                            }
                            if (nameExist.value) {
                              return '用户名已存在';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            nameExist.value = (false);
                            controller.name.value = (value);
                          },
                          decoration: const InputDecoration(
                              labelText: '用户名',
                              hintText: '请输入用户名',
                              isCollapsed: false,
                              contentPadding: EdgeInsets.only(
                                  top: 0, bottom: 0, left: 0, right: 0)),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Form(
                      key: passwordKey,
                      child: Focus(
                        onFocusChange: (value) {
                          if (!value) {
                            passwordKey.currentState!.validate();
                          }
                        },
                        child: TextFormField(
                          initialValue: controller.password.value,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请输入密码';
                            }
                            final pattern = RegExp(
                                r'^[a-zA-Z0-9-*/+-=:.~?!@#$%^&*()]{6,30}$');
                            if (!pattern.hasMatch(value)) {
                              return '密码格式错误';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            controller.password.value = (value);
                          },
                          obscureText: true,
                          decoration: const InputDecoration(
                              labelText: '密码',
                              hintText: '请输入密码',
                              isCollapsed: false,
                              contentPadding: EdgeInsets.only(
                                  top: 0, bottom: 0, left: 0, right: 0)),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 30,
                      child: FilledButton(
                          onPressed: () async {
                            if (!emailKey.currentState!.validate() ||
                                !codeKey.currentState!.validate() ||
                                !passwordKey.currentState!.validate()) {
                              return;
                            }
                            final isSuccess = await controller.register();
                            if (isSuccess) {
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                behavior: SnackBarBehavior.floating,
                                margin: EdgeInsets.only(
                                    bottom: 10, left: 100, right: 100),
                                content: Text('注册成功'),
                              ));
                              // appPop();
                              appPushReplacementNamed('/profile');
                            } else {
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                behavior: SnackBarBehavior.floating,
                                margin: EdgeInsets.only(
                                    bottom: 10, left: 100, right: 100),
                                content: Text('密码修改失败，请重试'),
                              ));
                            }
                          },
                          style: ButtonStyle(
                              shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5)))),
                          child: const Text('注册')),
                    ),
                    SizedBox(
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text('已有账号？'),
                            TextButton(
                                onPressed: () {
                                  appPushReplacementNamed('/login');
                                },
                                style: ButtonStyle(
                                  padding: WidgetStateProperty.all(
                                      const EdgeInsets.all(0)),
                                  overlayColor: WidgetStateProperty.all(
                                      Colors.transparent),
                                ),
                                child: const Text('登录'))
                          ],
                        ))
                  ],
                ),
              ),
            ),
            bottomNavigationBar: NavBar(
              children: [
                NavItem(
                    icon: Icons.arrow_back, title: '返回', onTap: () => appPop()),
              ],
            ),
          );
        });
  }
}
