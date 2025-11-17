import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:order_pad/models/category_model.dart';
import 'package:order_pad/widgets/colors.dart';

class CartPage extends StatefulWidget {
  final List<ProductModel> cartItems;
  final Function(ProductModel) onRemoveItem;
  final Function(ProductModel) onAddItem;
  final Function(ProductModel, int) onUpdateQuantity;

  const CartPage({
    super.key,
    required this.cartItems,
    required this.onRemoveItem,
    required this.onAddItem,
    required this.onUpdateQuantity,
  });

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  Map<ProductModel, int> itemQuantities = {};

  @override
  void initState() {
    super.initState();
    // Initialize quantities
    for (var item in widget.cartItems) {
      itemQuantities[item] = 1;
    }
  }

  double get totalAmount {
    double total = 0;
    itemQuantities.forEach((item, quantity) {
      total += double.parse(item.price) * quantity;
    });
    return total;
  }

  void updateQuantity(ProductModel item, int newQuantity) {
    setState(() {
      if (newQuantity <= 0) {
        itemQuantities.remove(item);
        widget.onRemoveItem(item);
      } else {
        itemQuantities[item] = newQuantity;
        widget.onUpdateQuantity(item, newQuantity);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Cart',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: SvgPicture.asset("assets/icons/basket.svg"),
            onPressed: () {},
          ),
        ],
      ),
      body: widget.cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    "assets/icons/basket.svg",
                    width: 80,
                    height: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Add items to get started',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Delivery info
                Container(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset("assets/icons/motor.svg", width: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Delivery to',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '61 Hopper street..',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down_rounded),
                    ],
                  ),
                ),

                // Cart items
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: itemQuantities.length,
                    itemBuilder: (context, index) {
                      final item = itemQuantities.keys.elementAt(index);
                      final quantity = itemQuantities[item]!;
                      
                      return Container(
                        margin: EdgeInsets.only(bottom: 16),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Product image
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Image.asset(
                                  item.image,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            
                            // Product details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '4 Bunch of ${item.name.toLowerCase()}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '\$${item.price}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Quantity controls and delete
                            Column(
                              children: [
                                // Delete button
                                GestureDetector(
                                  onTap: () => updateQuantity(item, 0),
                                  child: Container(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(
                                      Icons.delete_outline,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                
                                // Quantity controls
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => updateQuantity(item, quantity - 1),
                                      child: Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Icon(Icons.remove, size: 16),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      quantity.toString(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    GestureDetector(
                                      onTap: () => updateQuantity(item, quantity + 1),
                                      child: Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Icon(
                                          Icons.add,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Delivery progress
                Container(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'You are \$${(30 - totalAmount).toStringAsFixed(2)} away from free delivery',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: totalAmount / 30,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ],
                  ),
                ),

                // Go to Cart button
                Container(
                  margin: EdgeInsets.all(16),
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle checkout
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Submit Order (\$${totalAmount.toStringAsFixed(2)})',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            itemQuantities.values.fold(0, (sum, qty) => sum + qty).toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
