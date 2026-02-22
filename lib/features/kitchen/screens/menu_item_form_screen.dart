import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/theme_config.dart';
import '../../../core/models/menu_model.dart';
import '../../menu/providers/menu_provider.dart';
import '../providers/kitchen_provider.dart';

class MenuItemFormScreen extends StatefulWidget {
  final int? itemId;

  const MenuItemFormScreen({super.key, this.itemId});

  @override
  State<MenuItemFormScreen> createState() => _MenuItemFormScreenState();
}

class _MenuItemFormScreenState extends State<MenuItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _itemNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _allergyIndicationController = TextEditingController();
  final _costController = TextEditingController();
  final _imagePathController = TextEditingController();
  final _availableTimingController = TextEditingController();
  final _preparationTimeController = TextEditingController();
  final _quantityController = TextEditingController();

  bool _isVeg = true;
  bool _isHalal = false;
  int _spicyLevel = 1;
  List<int> _selectedLabelIds = [];
  bool _isLoading = false;
  bool _isInitialized = false;

  bool get isEditing => widget.itemId != null;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  Future<void> _initializeForm() async {
    final menuProvider = context.read<MenuProvider>();

    // Fetch labels
    await menuProvider.fetchLabels();

    // If editing, load existing item
    if (isEditing) {
      setState(() => _isLoading = true);
      final item = await menuProvider.getMenuItemById(widget.itemId!);
      if (item != null && mounted) {
        _populateForm(item);
      }
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }

    if (mounted) {
      setState(() => _isInitialized = true);
    }
  }

  void _populateForm(MenuItem item) {
    _itemNameController.text = item.itemName;
    _descriptionController.text = item.description ?? '';
    _ingredientsController.text = item.ingredients ?? '';
    _allergyIndicationController.text = item.allergyIndication ?? '';
    _costController.text = item.cost.toStringAsFixed(2);
    _imagePathController.text = item.imagePath ?? '';
    _availableTimingController.text = item.availableTiming ?? '';
    _preparationTimeController.text = item.preparationTimeMinutes.toString();
    _quantityController.text = (item.quantityAvailable ?? 0).toString();
    _isVeg = item.isVeg;
    _isHalal = item.isHalal;
    _spicyLevel = item.spicyLevel ?? 1;
    _selectedLabelIds = item.labels?.map((l) => l.id).toList() ?? [];
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _descriptionController.dispose();
    _ingredientsController.dispose();
    _allergyIndicationController.dispose();
    _costController.dispose();
    _imagePathController.dispose();
    _availableTimingController.dispose();
    _preparationTimeController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final menuProvider = context.read<MenuProvider>();
    final kitchenProvider = context.read<KitchenProvider>();
    final kitchenId = kitchenProvider.myKitchen?.id;

    final data = {
      'itemName': _itemNameController.text.trim(),
      'description': _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      'ingredients': _ingredientsController.text.trim().isNotEmpty
          ? _ingredientsController.text.trim()
          : null,
      'allergyIndication': _allergyIndicationController.text.trim().isNotEmpty
          ? _allergyIndicationController.text.trim()
          : null,
      'cost': double.parse(_costController.text),
      'imagePath': _imagePathController.text.trim().isNotEmpty
          ? _imagePathController.text.trim()
          : null,
      'availableTiming': _availableTimingController.text.trim().isNotEmpty
          ? _availableTimingController.text.trim()
          : null,
      'preparationTimeMinutes': int.tryParse(_preparationTimeController.text) ?? 30,
      'quantityAvailable': int.tryParse(_quantityController.text) ?? 0,
      'isVeg': _isVeg,
      'isHalal': _isHalal,
      'spicyLevel': _spicyLevel,
      'labelIds': _selectedLabelIds,
    };

    bool success;
    if (isEditing) {
      success = await menuProvider.updateMenuItem(widget.itemId!, data);
    } else {
      success = await menuProvider.addMenuItem(data, kitchenId: kitchenId);
    }

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Menu item updated successfully' : 'Menu item added successfully'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(menuProvider.error ?? 'Failed to save menu item'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteItem() async {
    if (!isEditing) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Menu Item'),
        content: const Text('Are you sure you want to delete this menu item? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() => _isLoading = true);
      final menuProvider = context.read<MenuProvider>();
      final success = await menuProvider.deactivateMenuItem(widget.itemId!);
      setState(() => _isLoading = false);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Menu item deleted'), backgroundColor: Colors.green),
          );
          context.pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete menu item'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Menu Item' : 'Add Menu Item'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _isLoading ? null : _deleteItem,
            ),
        ],
      ),
      body: _isLoading && !_isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Item Name
                  TextFormField(
                    controller: _itemNameController,
                    decoration: const InputDecoration(
                      labelText: 'Item Name *',
                      hintText: 'Enter item name',
                      prefixIcon: Icon(Icons.restaurant_menu),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Item name is required';
                      }
                      if (value.length < 2 || value.length > 100) {
                        return 'Name must be 2-100 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Enter item description',
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                    maxLength: 500,
                  ),
                  const SizedBox(height: 16),

                  // Ingredients
                  TextFormField(
                    controller: _ingredientsController,
                    decoration: const InputDecoration(
                      labelText: 'Ingredients',
                      hintText: 'List main ingredients',
                      prefixIcon: Icon(Icons.list_alt),
                    ),
                    maxLines: 2,
                    maxLength: 500,
                  ),
                  const SizedBox(height: 16),

                  // Allergy Indication
                  TextFormField(
                    controller: _allergyIndicationController,
                    decoration: const InputDecoration(
                      labelText: 'Allergy Information',
                      hintText: 'e.g., Contains dairy, nuts',
                      prefixIcon: Icon(Icons.warning_amber),
                    ),
                    maxLength: 200,
                  ),
                  const SizedBox(height: 16),

                  // Cost
                  TextFormField(
                    controller: _costController,
                    decoration: const InputDecoration(
                      labelText: 'Price *',
                      hintText: 'Enter price',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Price is required';
                      }
                      final price = double.tryParse(value);
                      if (price == null || price < 0.01 || price > 9999.99) {
                        return 'Price must be between 0.01 and 9999.99';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Image Path
                  TextFormField(
                    controller: _imagePathController,
                    decoration: const InputDecoration(
                      labelText: 'Image URL',
                      hintText: 'Enter image URL',
                      prefixIcon: Icon(Icons.image),
                    ),
                    maxLength: 255,
                  ),
                  const SizedBox(height: 16),

                  // Available Timing
                  TextFormField(
                    controller: _availableTimingController,
                    decoration: const InputDecoration(
                      labelText: 'Available Timing',
                      hintText: 'e.g., Lunch & Dinner',
                      prefixIcon: Icon(Icons.access_time),
                    ),
                    maxLength: 100,
                  ),
                  const SizedBox(height: 16),

                  // Preparation Time & Quantity Row
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _preparationTimeController,
                          decoration: const InputDecoration(
                            labelText: 'Prep Time (min)',
                            hintText: '30',
                            prefixIcon: Icon(Icons.timer),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final time = int.tryParse(value);
                              if (time == null || time < 1 || time > 180) {
                                return '1-180 min';
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _quantityController,
                          decoration: const InputDecoration(
                            labelText: 'Quantity',
                            hintText: '50',
                            prefixIcon: Icon(Icons.inventory),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final qty = int.tryParse(value);
                              if (qty == null || qty < 0) {
                                return 'Invalid';
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Dietary Options
                  const Text(
                    'Dietary Options',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: SwitchListTile(
                          title: const Text('Vegetarian'),
                          subtitle: const Text('No meat'),
                          value: _isVeg,
                          onChanged: (value) => setState(() => _isVeg = value),
                          activeTrackColor: ThemeConfig.primaryColor.withValues(alpha: 0.5),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      Expanded(
                        child: SwitchListTile(
                          title: const Text('Halal'),
                          subtitle: const Text('Halal certified'),
                          value: _isHalal,
                          onChanged: (value) => setState(() => _isHalal = value),
                          activeTrackColor: ThemeConfig.primaryColor.withValues(alpha: 0.5),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Spicy Level
                  const Text(
                    'Spicy Level',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _spicyLevel.toDouble(),
                          min: 1,
                          max: 5,
                          divisions: 4,
                          label: _getSpicyLevelLabel(_spicyLevel),
                          activeColor: _getSpicyColor(_spicyLevel),
                          onChanged: (value) => setState(() => _spicyLevel = value.round()),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getSpicyColor(_spicyLevel).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _getSpicyLevelLabel(_spicyLevel),
                          style: TextStyle(
                            color: _getSpicyColor(_spicyLevel),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Labels
                  _buildLabelsSection(),
                  const SizedBox(height: 32),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeConfig.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              isEditing ? 'Update Menu Item' : 'Add Menu Item',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _buildLabelsSection() {
    return Consumer<MenuProvider>(
      builder: (context, menuProvider, _) {
        final labels = menuProvider.labels;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Labels',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: _showAddLabelDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Label'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (labels.isEmpty)
              const Text(
                'No labels available. Add labels to categorize your items.',
                style: TextStyle(color: Colors.grey),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: labels.map((label) {
                  final isSelected = _selectedLabelIds.contains(label.id);
                  return FilterChip(
                    label: Text(label.name),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedLabelIds.add(label.id);
                        } else {
                          _selectedLabelIds.remove(label.id);
                        }
                      });
                    },
                    selectedColor: ThemeConfig.primaryColor.withValues(alpha: 0.2),
                    checkmarkColor: ThemeConfig.primaryColor,
                  );
                }).toList(),
              ),
          ],
        );
      },
    );
  }

  Future<void> _showAddLabelDialog() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Label'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Label Name *',
                hintText: 'e.g., Organic',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Optional description',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result == true && nameController.text.trim().isNotEmpty && mounted) {
      final menuProvider = context.read<MenuProvider>();
      final newLabel = await menuProvider.createLabel(
        nameController.text.trim(),
        description: descriptionController.text.trim().isNotEmpty
            ? descriptionController.text.trim()
            : null,
      );

      if (newLabel != null && mounted) {
        setState(() {
          _selectedLabelIds.add(newLabel.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Label added'), backgroundColor: Colors.green),
        );
      }
    }
  }

  String _getSpicyLevelLabel(int level) {
    switch (level) {
      case 1:
        return 'Mild';
      case 2:
        return 'Medium';
      case 3:
        return 'Spicy';
      case 4:
        return 'Very Spicy';
      case 5:
        return 'Extremely Spicy';
      default:
        return 'Unknown';
    }
  }

  Color _getSpicyColor(int level) {
    switch (level) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.lime;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.deepOrange;
      case 5:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

