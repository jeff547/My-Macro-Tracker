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
  Map<String, int> foodList = {};
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    final initialQuery = widget.predictedLabel?.trim();
    if (initialQuery != null && initialQuery.isNotEmpty) {
      getFoodList(initialQuery);
    }
  }

  Future<void> getFoodList(String value) async {
    final query = value.trim();
    if (query.isEmpty) {
      setState(() {
        foodList = {};
        errorMessage = 'Enter a search term to begin.';
        isLoading = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final results = await fetchFoodList(query);
      if (!mounted) return;
      setState(() {
        foodList = results;
        isLoading = false;
        errorMessage = results.isEmpty ? 'No foods found for "$query".' : null;
      });
    } on FoodApiException catch (error) {
      if (!mounted) return;
      setState(() {
        errorMessage = error.message;
        foodList = {};
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Something went wrong while searching.';
        foodList = {};
        isLoading = false;
      });
    }
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
                  child: Builder(
                    builder: (context) {
                      if (isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (errorMessage != null) {
                        return Center(
                          child: Text(
                            errorMessage!,
                            textAlign: TextAlign.center,
                            style: CustomTextStyles.configBody2,
                          ),
                        );
                      }
                      if (foodList.isEmpty) {
                        return Center(
                          child: Text(
                            'Search for a food to see results.',
                            style: CustomTextStyles.configBody2,
                          ),
                        );
                      }
                      return FoodSearchList(
                        foodList: foodList,
                        selectedDate: widget.selectedDate,
                      );
                    },
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
    final entries = foodList.entries.toList();
    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Nutrition(
                  fdcId: entry.value,
                  foodName: entry.key,
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
                              entry.key,
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
