import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_diary/presentation/screens/main_pages/dashboard.dart';
import 'package:food_diary/presentation/widgets/theme.dart';
import 'package:scroll_date_picker/scroll_date_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool imperialSystem = false;
late bool gender;
late double height;
late double weight;
late double age;
late double goalWeight;
late double weightPerWeek;
late double activityLevel;

void goNext(controller) {
  controller.nextPage(
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeInOutCubic,
  );
}

String getUnit() {
  if (imperialSystem) {
    return "lbs";
  }
  return "kgs";
}

String getHeightUnit() {
  if (imperialSystem) {
    return "in";
  }
  return "cm";
}

void calulateNutritonPlan() async {
  final prefs = await SharedPreferences.getInstance();
  late double estimatedProtein;
  late double estimatedFats;
  late double estimatedCarbs;
  late double calories;
  late double caloriesToChangePerDay;
  if (imperialSystem) {
    weight /= 2.205;
    height *= 2.54;
    goalWeight /= 2.025;
    caloriesToChangePerDay = weightPerWeek * 3500 / 7;
  } else {
    caloriesToChangePerDay = weightPerWeek * 7700 / 7;
  }

  if (gender) {
    calories = (10 * weight) + (6.25 * height) - (5 * age) + 5;
  } else {
    calories = (10 * weight) + (6.25 * height) - (5 * age) - 161;
  }
  calories *= activityLevel;

  if (goalWeight > weight) {
    calories += caloriesToChangePerDay;
  } else if (goalWeight < weight) {
    calories -= caloriesToChangePerDay;
  }

  calories = calories.round().toDouble();
  estimatedProtein = double.parse((calories * 0.3 / 4).toStringAsFixed(1));
  estimatedCarbs = double.parse((calories * 0.4 / 4).toStringAsFixed(1));
  estimatedFats = double.parse((calories * 0.3 / 9).toStringAsFixed(1));

  await prefs.setDouble("estimatedCalories", calories);
  await prefs.setDouble("estimatedProtein", estimatedProtein);
  await prefs.setDouble("estimatedCarbs", estimatedCarbs);
  await prefs.setDouble("estimatedFats", estimatedFats);
  await prefs.setBool("hasCompletedOnboarding", true);
}

class GenderPage extends StatefulWidget {
  const GenderPage({super.key, required this.controller});
  final PageController controller;

  @override
  State<GenderPage> createState() => _GenderPageState();
}

class _GenderPageState extends State<GenderPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Your Gender',
            style: CustomTextStyles.configTitle,
          ),
          const SizedBox(height: 20),
          // ignore: sized_box_for_whitespace
          Container(
            width: 300,
            child: Text(
              textAlign: TextAlign.left,
              'This will be used to create your personal nutritional plan using our algorithms.',
              style: CustomTextStyles.configBody,
            ),
          ),
          const SizedBox(height: 80),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: SizedBox(
                width: 300,
                height: 150,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      gender = true;
                    });
                    goNext(widget.controller);
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      const Color(0xFF87CEEB),
                    ),
                  ),
                  child: Text("MALE", style: CustomTextStyles.configButonText),
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: SizedBox(
                width: 300,
                height: 150,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      const Color(0xFFFFD1DC),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      gender = false;
                    });
                    goNext(widget.controller);
                  },
                  child:
                      Text("FEMALE", style: CustomTextStyles.configButonText),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key, required this.controller});
  final PageController controller;

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  double _sliderVal = 0;

  double getActivityMultipler(double val) {
    switch (val) {
      case 0:
        return 1.2;
      case 25:
        return 1.375;
      case 50:
        return 1.55;
      case 75:
        return 1.725;
      case 100:
        return 1.9;
    }
    return 0;
  }

  String getLabel(double val) {
    switch (val) {
      case 0:
        return "Sedentary";
      case 25:
        return "Lightly Active";
      case 50:
        return "Moderately Active";
      case 75:
        return "Active";
      case 100:
        return "Very Active";
    }
    return "";
  }

  String getBodyText(double val) {
    switch (val) {
      case 0:
        return "This reflects a lifestyle with very little movement, where most of the day is spent sitting or inactive. Common for those with desk jobs or minimal physical exertion.";
      case 25:
        return "This level includes occasional movement or light exercise, such as short walks or light chores. It’s typical for those who perform basic daily activities without much additional effort.";
      case 50:
        return "Someone in this category engages in moderate exercise several times a week or has a lifestyle that involves regular physical movement. This could include activities like brisk walking, light jogging, or recreational sports.";
      case 75:
        return "Individuals who are active participate in regular exercise or have a physically demanding job. They are generally on their feet most of the day and engage in sustained physical activity.";
      case 100:
        return "This describes a high level of physical activity, such as intense daily workouts or physically demanding labor. People in this group regularly engage in challenging physical exercises or sports.";
    }
    return "";
  }

  Widget? getImage(double val) {
    switch (val) {
      case 0:
        return Image.asset("assets/images/comfort-zone.png");
      case 25:
        return Image.asset("assets/images/dog-walking.png");
      case 50:
        return Image.asset("assets/images/running.png");
      case 75:
        return Image.asset("assets/images/sports.png");
      case 100:
        return Image.asset("assets/images/workout.png");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Center(
        child: Column(
          children: [
            Text(
              "How active are you?",
              style: CustomTextStyles.configTitle3,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: 180,
                height: 180,
                child: getImage(_sliderVal),
              ),
            ),
            const SizedBox(height: 5),
            Slider(
              max: 100,
              divisions: 4,
              inactiveColor: Colors.white,
              label: getLabel(_sliderVal),
              activeColor: const Color.fromARGB(255, 159, 144, 6),
              value: _sliderVal,
              onChanged: (double val) {
                setState(() {
                  _sliderVal = val;
                });
              },
            ),
            const SizedBox(height: 10),
            Text(
              getLabel(_sliderVal),
              style: CustomTextStyles.configBody3,
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                getBodyText(_sliderVal),
                style: CustomTextStyles.configBody,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 120,
              width: 300,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    activityLevel = getActivityMultipler(_sliderVal);
                  });
                  goNext(widget.controller);
                },
                child: Text(
                  "Next",
                  style: CustomTextStyles.configTitle2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GoalPage extends StatefulWidget {
  const GoalPage({super.key, required this.controller});
  final PageController controller;

  @override
  State<GoalPage> createState() => _GoalPageState();
}

class _GoalPageState extends State<GoalPage> {
  late FixedExtentScrollController _controller;
  // ignore: prefer_final_fields
  List<bool> _selections = [false, false, false, false];
  bool finalVisibile = false;

  @override
  void initState() {
    super.initState();
    _controller = FixedExtentScrollController(initialItem: weight.toInt());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Center(
        child: Column(
          children: [
            Text(
              "Finish Your Nutriton Plan",
              style: CustomTextStyles.configTitle3,
            ),
            const SizedBox(height: 20),
            Container(
              width: 350,
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: const Color.fromARGB(255, 24, 24, 24),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    "Select Target Weight:",
                    style: CustomTextStyles.configBody,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 15),
                      const Icon(
                        Icons.arrow_right,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 40,
                        height: 250,
                        child: ListWheelScrollView(
                          controller: _controller,
                          onSelectedItemChanged: (int index) {
                            setState(() {
                              goalWeight = index.toDouble();
                            });
                            HapticFeedback.selectionClick();
                          },
                          itemExtent: 35,
                          perspective: 0.005,
                          diameterRatio: 1.2,
                          physics: const FixedExtentScrollPhysics(),
                          children: List<Widget>.generate(
                            1001,
                            (index) => Container(
                              alignment: Alignment.center,
                              child: Text(
                                '$index',
                                style: CustomTextStyles.configBody1,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(getUnit(), style: CustomTextStyles.configBody),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Container(
              width: 300,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: const Color.fromARGB(255, 24, 24, 24),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      "Weight Change Per Week:",
                      style: CustomTextStyles.configBody,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: const Color.fromARGB(255, 74, 74, 74),
                    ),
                    child: ToggleButtons(
                      borderColor: const Color.fromARGB(255, 128, 128, 128),
                      color: const Color.fromARGB(255, 255, 255, 255),
                      selectedColor: const Color.fromARGB(255, 254, 254, 254),
                      fillColor: const Color.fromARGB(255, 58, 94, 67),
                      selectedBorderColor:
                          const Color.fromARGB(255, 63, 152, 86),
                      isSelected: _selections,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Text("0.5 ${getUnit()}"),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Text("1 ${getUnit()}"),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Text("1.5 ${getUnit()}"),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Text("2 ${getUnit()}"),
                        ),
                      ],
                      onPressed: (int index) {
                        setState(
                          () {
                            finalVisibile = true;
                            for (int i = 0; i < _selections.length; i++) {
                              _selections[i] = false;
                              if (i == index) {
                                _selections[index] = true;
                              }
                            }
                            switch (index) {
                              case 0:
                                weightPerWeek = 0.5;
                              case 1:
                                weightPerWeek = 1;
                              case 2:
                                weightPerWeek = 1.5;
                              case 3:
                                weightPerWeek = 2;
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              height: 70,
              width: 200,
              child: Visibility(
                visible: finalVisibile,
                child: ElevatedButton(
                  onPressed: () {
                    calulateNutritonPlan();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NutritionDashboard()),
                    );
                  },
                  child: Text(
                    "Finalize",
                    style: CustomTextStyles.configBody1,
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

class WeightPage extends StatefulWidget {
  const WeightPage({super.key, required this.controller});
  final PageController controller;

  @override
  State<WeightPage> createState() => _WeightPageState();
}

class _WeightPageState extends State<WeightPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<bool> _selections = [imperialSystem, !imperialSystem];
  bool _visibleNextButton = false;

  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Center(
          child: Column(
            children: [
              Text(
                "What's your current weight?",
                style: CustomTextStyles.introPageTitle,
              ),
              const SizedBox(height: 50),
              Container(
                width: 350,
                height: 320,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: const Color.fromARGB(255, 24, 24, 24),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: Image.asset(
                        "assets/images/weight.gif",
                        fit: BoxFit.cover,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 5),
                        SizedBox(
                          width: 150,
                          child: TextFormField(
                            key: _formKey,
                            onFieldSubmitted: (value) {
                              FocusScope.of(context).unfocus();
                              setState(() {
                                weight = double.parse(value);
                                _visibleNextButton = true;
                              });
                            },
                            controller: _textController,
                            maxLength: 3,
                            keyboardType: const TextInputType.numberWithOptions(
                                signed: true),
                            style: CustomTextStyles.configBody,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              labelText: "Enter Weight",
                              hintTextDirection: TextDirection.rtl,
                              hintText: getUnit(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ToggleButtons(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        selectedColor: const Color.fromARGB(255, 254, 254, 254),
                        fillColor: const Color.fromARGB(255, 58, 94, 67),
                        isSelected: _selections,
                        children: const [
                          Text("lb"),
                          Text('kg'),
                        ],
                        onPressed: (int index) {
                          setState(() {
                            int other = 0;
                            for (int i = 0; i < _selections.length; i++) {
                              if (i != index) {
                                other = i;
                              }
                              if (index == i && _selections[index] == false) {
                                _selections[index] = true;
                              }
                            }
                            _selections[other] = false;

                            if (_selections[0] == true) {
                              setState(() {
                                imperialSystem = true;
                              });
                            } else {
                              setState(() {
                                imperialSystem = false;
                              });
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 75),
              SizedBox(
                height: 120,
                width: 300,
                child: Visibility(
                  visible: _visibleNextButton,
                  child: ElevatedButton(
                    onPressed: () {
                      goNext(widget.controller);
                    },
                    child: Text(
                      "Next",
                      style: CustomTextStyles.configTitle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HeightPage extends StatefulWidget {
  const HeightPage({super.key, required this.controller});
  final PageController controller;

  @override
  State<HeightPage> createState() => _HeightPageState();
}

class _HeightPageState extends State<HeightPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<bool> _selections = [imperialSystem, !imperialSystem];
  bool _visibleNextButton = false;

  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Center(
          child: Column(
            children: [
              Text(
                "How tall are you?",
                style: CustomTextStyles.introPageTitle,
              ),
              const SizedBox(height: 50),
              Container(
                width: 350,
                height: 320,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: const Color.fromARGB(255, 24, 24, 24),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: Image.asset(
                        "assets/images/height.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 5),
                        SizedBox(
                          width: 150,
                          child: TextFormField(
                            key: _formKey,
                            onFieldSubmitted: (value) {
                              FocusScope.of(context).unfocus();
                              setState(() {
                                height = double.parse(value);
                                _visibleNextButton = true;
                              });
                            },
                            controller: _textController,
                            maxLength: 3,
                            keyboardType: const TextInputType.numberWithOptions(
                                signed: true),
                            style: CustomTextStyles.configBody,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              labelText: "Enter Height",
                              hintTextDirection: TextDirection.rtl,
                              hintText: getHeightUnit(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ToggleButtons(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        selectedColor: const Color.fromARGB(255, 254, 254, 254),
                        fillColor: const Color.fromARGB(255, 58, 94, 67),
                        isSelected: _selections,
                        children: const [
                          Text("in"),
                          Text('cm'),
                        ],
                        onPressed: (int index) {
                          setState(() {
                            int other = 0;
                            for (int i = 0; i < _selections.length; i++) {
                              if (i != index) {
                                other = i;
                              }
                              if (index == i && _selections[index] == false) {
                                _selections[index] = true;
                              }
                            }
                            _selections[other] = false;

                            if (_selections[0]) {
                              setState(() {
                                imperialSystem = true;
                              });
                            } else {
                              setState(() {
                                imperialSystem = false;
                              });
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 75),
              SizedBox(
                height: 120,
                width: 300,
                child: Visibility(
                  visible: _visibleNextButton,
                  child: ElevatedButton(
                    onPressed: () {
                      goNext(widget.controller);
                    },
                    child: Text(
                      "Next",
                      style: CustomTextStyles.configTitle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AgePage extends StatefulWidget {
  const AgePage({super.key, required this.controller});

  final PageController controller;

  @override
  State<AgePage> createState() => _AgePageState();
}

class _AgePageState extends State<AgePage> {
  DateTime _selectedDate = DateTime.now();
  bool _visibleNextButton = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        children: [
          Text(
            "When were you born?",
            style: CustomTextStyles.configTitle2,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 300,
            height: 300,
            child: ScrollDatePicker(
              scrollViewOptions: const DatePickerScrollViewOptions(
                year: ScrollViewDetailOptions(
                  selectedTextStyle: TextStyle(
                    color: Colors.white,
                  ),
                  textStyle: TextStyle(
                    color: Colors.white,
                  ),
                ),
                month: ScrollViewDetailOptions(
                  textScaleFactor: 1,
                  selectedTextStyle: TextStyle(
                    color: Colors.white,
                  ),
                  textStyle: TextStyle(
                    color: Colors.white,
                  ),
                ),
                day: ScrollViewDetailOptions(
                  selectedTextStyle: TextStyle(
                    color: Colors.white,
                  ),
                  textStyle: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              options: const DatePickerOptions(
                backgroundColor: Colors.black,
              ),
              selectedDate: _selectedDate,
              onDateTimeChanged: (DateTime value) {
                setState(() {
                  _visibleNextButton = true;
                  _selectedDate = value;
                  Duration diff = DateTime.now().difference(value);
                  age = diff.inDays / 365;
                  age = age.floorToDouble();
                });
              },
            ),
          ),
          const SizedBox(height: 120),
          SizedBox(
            height: 120,
            width: 300,
            child: Visibility(
              visible: _visibleNextButton,
              child: ElevatedButton(
                onPressed: () {
                  goNext(widget.controller);
                },
                child: Text(
                  "Next",
                  style: CustomTextStyles.configTitle2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
