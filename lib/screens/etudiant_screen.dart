import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class HomeModel {
  void dispose() {}
}

HomeModel createModel(BuildContext context, HomeModel Function() builder) {
  return builder();
}

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  static String routeName = 'Home';
  static String routePath = '/home';

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> with TickerProviderStateMixin {
  late HomeModel _model;
  late AnimationController _containerController;
  late AnimationController _text1Controller;
  late AnimationController _text2Controller;
  late AnimationController _rowController;

  late Animation<double> _containerFade;
  late Animation<double> _containerScale;
  late Animation<double> _text1Fade;
  late Animation<Offset> _text1Slide;
  late Animation<double> _text2Fade;
  late Animation<Offset> _text2Slide;
  late Animation<double> _rowFade;
  late Animation<double> _rowScale;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomeModel());

    _containerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _containerFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _containerController, curve: Curves.easeInOut));
    _containerScale = Tween<double>(begin: 3.0, end: 1.0).animate(CurvedAnimation(parent: _containerController, curve: Curves.easeInOut));

    _text1Controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _text1Fade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _text1Controller, curve: Curves.easeInOut));
    _text1Slide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(CurvedAnimation(parent: _text1Controller, curve: Curves.easeInOut));

    _text2Controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _text2Fade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _text2Controller, curve: Curves.easeInOut));
    _text2Slide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(CurvedAnimation(parent: _text2Controller, curve: Curves.easeInOut));

    _rowController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _rowFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _rowController, curve: Curves.easeInOut));
    _rowScale = Tween<double>(begin: 0.6, end: 1.0).animate(CurvedAnimation(parent: _rowController, curve: Curves.bounceOut));

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _containerController.forward();
      await Future.delayed(const Duration(milliseconds: 350));
      _text1Controller.forward();
      await Future.delayed(const Duration(milliseconds: 50));
      _text2Controller.forward();
      await Future.delayed(const Duration(milliseconds: 300));
      _rowController.forward();
    });
  }

  @override
  void dispose() {
    _model.dispose();
    _containerController.dispose();
    _text1Controller.dispose();
    _text2Controller.dispose();
    _rowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: cs.surface,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: FadeTransition(
                opacity: _containerFade,
                child: ScaleTransition(
                  scale: _containerScale,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white.withOpacity(0), cs.surface],
                        stops: const [0, 1],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock_rounded, size: 100, color: cs.primary),
                        Padding(
                          padding: const EdgeInsets.only(top: 44),
                          child: FadeTransition(
                            opacity: _text1Fade,
                            child: SlideTransition(
                              position: _text1Slide,
                              child: Text('Bonjour!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: cs.onSurface)),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(43, 8, 43, 0),
                          child: FadeTransition(
                            opacity: _text2Fade,
                            child: SlideTransition(
                              position: _text2Slide,
                              child: Text(
                                'Merci de nous rejoindre ! Accédez à votre compte ou créez-en un nouveau.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14, color: cs.onSurface.withOpacity(0.6)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 44),
              child: FadeTransition(
                opacity: _rowFade,
                child: ScaleTransition(
                  scale: _rowScale,
                  child: SizedBox(
                    width: 230,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/page-de-connexion'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: Colors.white,
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Commencez !', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
