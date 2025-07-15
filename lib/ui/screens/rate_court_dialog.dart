import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/utils/colors.dart';
import 'package:flutter/material.dart';

class RateCourtDialog extends StatefulWidget {
  final String courtName;
  final String courtLocation;
  final String courtImage;
  final Function(int rating, String review) onSubmit;

  const RateCourtDialog({
    super.key,
    required this.courtName,
    required this.courtLocation,
    required this.courtImage,
    required this.onSubmit,
  });

  @override
  State<RateCourtDialog> createState() => _RateCourtDialogState();
}

class _RateCourtDialogState extends State<RateCourtDialog> {
  int selectedRating = 0;
  final TextEditingController _reviewController = TextEditingController();
  bool get isFormValid =>
      selectedRating > 0 && _reviewController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        decoration: BoxDecoration(
          color: appWhiteColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Rate the Court",
                        style: TextStyle(
                          fontFamily: TempLanguage.poppins,
                          fontSize: 22,
                          color: appBlackColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close))
                  ],
                ),

                // Court Info Section
                Row(
                  children: [
                    // Court Image
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: AssetImage(widget.courtImage),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    // Court Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.courtName,
                            style: TextStyle(
                              fontFamily: TempLanguage.poppins,
                              fontSize: 18,
                              color: appBlackColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.courtLocation,
                            style: TextStyle(
                              fontFamily: TempLanguage.poppins,
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // Star Rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedRating = index + 1;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          index < selectedRating
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 36,
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 25),

                // Divider
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  height: 1,
                  color: Colors.grey.shade300,
                ),

                const SizedBox(height: 25),

                // Write a Review Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Write a Review",
                      style: TextStyle(
                        fontFamily: TempLanguage.poppins,
                        fontSize: 18,
                        color: appBlackColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _reviewController,
                        maxLines: null,
                        expands: true,
                        onChanged: (value) {
                          setState(() {
                            // Trigger rebuild to update button state
                          });
                        },
                        decoration: InputDecoration(
                          hintText: "Write your review here...",
                          hintStyle: TextStyle(
                            fontFamily: TempLanguage.poppins,
                            fontSize: 14,
                            color: Colors.grey.shade500,
                            height: 1.5,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(15),
                        ),
                        style: TextStyle(
                          fontFamily: TempLanguage.poppins,
                          fontSize: 14,
                          color: appBlackColor,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Rate Button
                GestureDetector(
                  onTap: isFormValid
                      ? () {
                          widget.onSubmit(
                              selectedRating, _reviewController.text.trim());
                          Navigator.pop(context);
                        }
                      : null,
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isFormValid ? appGreenColor : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Center(
                      child: Text(
                        "Rate",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: TempLanguage.poppins,
                          fontSize: 18,
                          color: appWhiteColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }
}
