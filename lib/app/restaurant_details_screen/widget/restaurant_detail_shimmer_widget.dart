import 'package:customer/widget/shimmer/box_shimmer.dart';
import 'package:flutter/material.dart';

Widget resturantDetailsShimmer() {
  return Padding(
    padding: const EdgeInsets.all(
      16,
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            boxShimmer(
              height: 25,
              width: 100,
            ),
            boxShimmer(
              height: 25,
              width: 80,
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            boxShimmer(
              height: 15,
              width: 200,
            ),
            boxShimmer(
              height: 15,
              width: 100,
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          children: [
            boxShimmer(
              height: 30,
              width: 100,
              borderRadius: 20,
            ),
            SizedBox(
              width: 5,
            ),
            boxShimmer(
              height: 10,
              width: 10,
              borderRadius: 100,
            ),
            SizedBox(
              width: 5,
            ),
            boxShimmer(
              height: 15,
              width: 100,
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        boxShimmer(
          height: 25,
          width: 50,
        ),
        SizedBox(
          height: 10,
        ),
        boxShimmer(
          height: 45,
          width: double.infinity,
          borderRadius: 5,
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          children: [
            boxShimmer(
              height: 25,
              width: 50,
            ),
            SizedBox(
              width: 10,
            ),
            boxShimmer(
              height: 25,
              width: 50,
            ),
            SizedBox(
              width: 10,
            ),
            boxShimmer(
              height: 35,
              width: 60,
            ),
          ],
        ),
        SizedBox(height: 10,),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: 5,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(
                  bottom: 8.0,
                ),
                child: boxShimmer(
                  height: 80,
                  width: 100,
                ),
              );
            },
          ),
        )
      ],
    ),
  );
}
