import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String productName;
  final String? productRegion;
  final Timestamp? productTime;
  final String imagePath;
  final int productPrice;

  const ProductCard({
    super.key,
    required this.productName,
    this.productRegion,
    this.productTime,
    required this.imagePath,
    required this.productPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 100, height: 100, child: Image.asset(imagePath)),
        const SizedBox(
          width: 8.0,
        ),
        Column(
          children: [
            Container(
              width: 250,
              height: 25,
              child: Text(
                productName,
                style: TextStyle(
                  fontSize: 15.0,
                ),
              ),
            ),
            Container(
              width: 250,
              height: 25,
              child: Row(
                children: [
                  Text(
                    productRegion == null ? '공백' : productRegion!,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12.0),
                  ),
                  const SizedBox(
                    width: 6.0,
                  ),
                  // Text(
                  //   productTime ==  ? '공백' : productTime!,
                  //   style: TextStyle(color: Colors.grey[600], fontSize: 12.0),
                  // ),
                ],
              ),
            ),
            Container(
              width: 250,
              height: 25,
              child: Text(
                '$productPrice원',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
              ),
            ),
            SizedBox(
              height: 25,
            )
          ],
        ),
      ],
    );
  }
}
