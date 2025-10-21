import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:customer/controllers/mart_address_controller.dart';

class MartAddressScreen extends StatelessWidget {
  const MartAddressScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(MartAddressController());
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Addresses',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onPressed: () {
              // TODO: Add more options
            },
          ),
        ],
      ),
      body: GetBuilder<MartAddressController>(
        builder: (controller) {
          return Column(
            children: [
              // Add New Address Card
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF5D56F3).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF5D56F3).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF5D56F3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.add_location_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: const Text(
                    'Add New Address',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5D56F3),
                    ),
                  ),
                  subtitle: const Text(
                    'Add a new delivery address',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  onTap: () => controller.addAddress(),
                ),
              ),
              
              // Addresses List
              Expanded(
                child: controller.addresses.isEmpty
                    ? _buildEmptyState()
                    : _buildAddressesList(controller),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF5D56F3).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.location_off,
              size: 40,
              color: Color(0xFF5D56F3),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Addresses Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your first delivery address',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressesList(MartAddressController controller) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: controller.addresses.length,
      itemBuilder: (context, index) {
        final address = controller.addresses[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: address.isDefault == true
                        ? const Color(0xFF5D56F3)
                        : Colors.grey.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: address.isDefault == true ? Colors.white : Colors.grey,
                    size: 20,
                  ),
                ),
                title: Text(
                  address.addressAs ?? 'Address ${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      address.getFullAddress(),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                    if (address.isDefault == true)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5D56F3).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Default',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5D56F3),
                          ),
                        ),
                      ),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        controller.editAddress(index);
                        break;
                      case 'delete':
                        controller.deleteAddress(index);
                        break;
                      case 'default':
                        controller.setDefaultAddress(index);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                    if (address.isDefault != true)
                      const PopupMenuItem(
                        value: 'default',
                        child: Row(
                          children: [
                            Icon(Icons.star, size: 16),
                            SizedBox(width: 8),
                            Text('Set as Default'),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
