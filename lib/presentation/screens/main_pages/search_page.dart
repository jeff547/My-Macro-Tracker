import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:food_diary/presentation/screens/main_pages/details_screen.dart';
import 'package:food_diary/presentation/widgets/fetch_food.dart';
import 'package:food_diary/presentation/widgets/theme.dart';

class SearchPage extends StatefulWidget {
  final String selectedDate;
  final String? predictedLabel;
  const SearchPage({
    super.key,
    required this.selectedDate,
    this.predictedLabel,
  });

  @override
  State<SearchPage> createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  bool isFoodListAvaliable = false;
  late Map<String, int> foodList;

  @override
  void initState() {
    super.initState();
    if (widget.predictedLabel != null) {
      getFoodList(widget.predictedLabel!);
    }
  }

  Future<void> getFoodList(String value) async {
    foodList = await fetchFoodList(value);
    setState(() {
      isFoodListAvaliable = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              children: [
                Row(
                  children: [
                    const BackButton(
                      color: Colors.white,
                    ),
                    const SizedBox(width: 55),
                    Text("Find Your Foods",
                        style: CustomTextStyles.searchTitle),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  width: 320,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: const Color(0xFF1E1E1E),
                  ),
                  child: TextField(
                    textAlignVertical: const TextAlignVertical(y: 0),
                    style: CustomTextStyles.calsLabel,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Search for a food...",
                      hintStyle: CustomTextStyles.calsLabel,
                      prefixIcon: const Icon(Icons.search),
                      prefixIconColor: Colors.white.withOpacity(0.5),
                    ),
                    onSubmitted: (String value) {
                      getFoodList(value);
                    },
                  ),
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: isFoodListAvaliable
                      ? FoodSearchList(
                          foodList: foodList, selectedDate: widget.selectedDate)
                      : const Center(
                          child: CircularProgressIndicator(),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FoodSearchList extends StatelessWidget {
  const FoodSearchList({
    super.key,
    required this.foodList,
    required this.selectedDate,
  });

  final Map<String, int> foodList;
  final String selectedDate;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: foodList.keys.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Nutrition(
                  query: foodList[foodList.keys.toList()[index]],
                  selectedDate: selectedDate,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Container(
                    height: 90,
                    width: 330,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: const Color(0xFF1E1E1E),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 173, 169, 169)
                              .withOpacity(0.2),
                          spreadRadius: 4,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: AutoSizeText(
                              textAlign: TextAlign.center,
                              foodList.keys.toList()[index],
                              style: CustomTextStyles.searchtext,
                            ),
                          ),
                          Container(
                              height: 32,
                              width: 32,
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 8, 112, 36),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                              ))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
