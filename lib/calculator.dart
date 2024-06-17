import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class BMICalculator extends StatefulWidget {
  @override
  _BMICalculatorState createState() => _BMICalculatorState();
}

class _BMICalculatorState extends State<BMICalculator> with SingleTickerProviderStateMixin {
  Color myColor = Colors.transparent;
  TextEditingController weightController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController mainResult = TextEditingController();

  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _fabScaleAnimation;
  late Animation<Color?> _fabColorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5),
    );

    _colorAnimation = ColorTween(begin: Color(0xFF6DD5ED), end: Color(0xFF2193B0)).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });

    _fabScaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _fabColorAnimation = ColorTween(begin: Colors.blue, end: Colors.green).animate(_animationController);

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    weightController.dispose();
    heightController.dispose();
    mainResult.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void calculateBMI(String weight, String height) {
    double weightValue = double.parse(weight);
    double heightValue = double.parse(height);
    double result = weightValue / (heightValue * heightValue);

    setState(() {
      mainResult.text = result.toStringAsFixed(2);
      if (result < 18.5) {
        myColor = Color(0xFF87B1D9);
      } else if (result >= 18.5 && result <= 24.9) {
        myColor = Color(0xFF3DD365);
      } else if (result >= 25 && result <= 29.9) {
        myColor = Color(0xFFEEE133);
      } else if (result >= 30 && result <= 34.9) {
        myColor = Color(0xFFFD802E);
      } else if (result >= 35) {
        myColor = Color(0xFFF95353);
      }
    });

    _colorAnimation = ColorTween(begin: Colors.transparent, end: myColor).animate(_animationController);

    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: AnimatedBuilder(
        animation: _fabScaleAnimation,
        builder: (context, child) {
          return FloatingActionButton(
            onPressed: () {
              calculateBMI(weightController.text, heightController.text);
            },
            child: Icon(Icons.calculate),
            backgroundColor: _fabColorAnimation.value,
            elevation: 0,
            foregroundColor: Colors.white,
            tooltip: "Calculate BMI",
          );
        },
      ),
      body: Stack(
        children: [
          AnimatedContainer(
            duration: Duration(seconds: 2),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_colorAnimation.value!, Color(0xFF2193B0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SizedBox(height: 60),
                    Text(
                      "BMI Calculator",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0038FF),
                        fontSize: 25,
                      ),
                    ),
                    SizedBox(height: 30),
                    _buildAnimatedTextField(
                      controller: weightController,
                      hintText: "Enter your weight (kg)",
                    ),
                    SizedBox(height: 15),
                    _buildAnimatedTextField(
                      controller: heightController,
                      hintText: "Enter your height (m)",
                    ),
                    SizedBox(height: 50),
                    AnimatedBuilder(
                      animation: _colorAnimation,
                      builder: (context, child) {
                        return Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _colorAnimation.value,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "BMI: ${mainResult.text}",
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildColorInfo(Color(0xFF87B1D9), "Underweight"),
                        _buildColorInfo(Color(0xFF3DD365), "Normal"),
                        _buildColorInfo(Color(0xFFEEE133), "Overweight"),
                        _buildColorInfo(Color(0xFFFD802E), "Obese"),
                        _buildColorInfo(Color(0xFFF95353), "Extreme"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedTextField({required TextEditingController controller, required String hintText}) {
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {});
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          border: Border.all(
            color: FocusScope.of(context).hasFocus ? Color(0xFF0038FF) : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorInfo(Color color, String label) {
    return Column(
      children: [
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        Text(label, style: TextStyle(fontSize: 15)),
      ],
    );
  }
}
