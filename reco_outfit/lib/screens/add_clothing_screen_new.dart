import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/wardrobe_provider.dart';
import '../models/clothing_item.dart';
import '../widgets/responsive_ui_components.dart';
import '../utils/responsive_utils.dart';
import '../theme/app_theme.dart';

class AddClothingScreen extends StatefulWidget {
  final ClothingItem? editingItem;

  const AddClothingScreen({super.key, this.editingItem});

  @override
  State<AddClothingScreen> createState() => _AddClothingScreenState();
}

class _AddClothingScreenState extends State<AddClothingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _tagsController = TextEditingController();
  
  String _selectedCategory = ClothingCategory.tops;
  String _selectedColor = ClothingColor.colors.first;
  String _selectedSeason = Season.allSeason;
  String? _imagePath;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.editingItem != null) {
      _populateFields();
    }
  }

  void _populateFields() {
    final item = widget.editingItem!;
    _nameController.text = item.name;
    _selectedCategory = item.category;
    _selectedColor = item.color;
    _selectedSeason = item.season;
    _imagePath = item.imagePath;
    _tagsController.text = item.tags.join(', ');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ResponsiveWidget(
            mobile: _buildMobileLayout(context),
            tablet: _buildTabletLayout(context),
            desktop: _buildDesktopLayout(context),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      title: Text(
        widget.editingItem != null ? 'Edit Item' : 'Add Clothing Item',
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
        ),
      ),
      actions: [
        ResponsiveWidget(
          mobile: IconButton(
            icon: const Icon(Icons.info_outline, color: AppTheme.primaryColor),
            onPressed: () => _showHelpDialog(context),
          ),
          tablet: ResponsiveButton(
            text: 'Help',
            icon: Icons.info_outline,
            size: ButtonSize.small,
            variant: ButtonVariant.text,
            onPressed: () => _showHelpDialog(context),
          ),
          desktop: ResponsiveButton(
            text: 'Tips & Help',
            icon: Icons.info_outline,
            size: ButtonSize.medium,
            variant: ButtonVariant.text,
            onPressed: () => _showHelpDialog(context),
          ),
        ),
        SizedBox(width: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 12, desktop: 16)),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: ResponsiveUtils.getResponsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageSection(context),
          SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 24, tablet: 28, desktop: 32)),
          _buildFormFields(context),
          SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 32, tablet: 40, desktop: 48)),
          _buildSaveButton(context),
          SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 16, tablet: 20, desktop: 24)),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: ResponsiveUtils.getResponsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section on the left
              Expanded(
                flex: 2,
                child: _buildImageSection(context),
              ),
              SizedBox(width: ResponsiveUtils.getResponsiveValue(context, mobile: 16, tablet: 24, desktop: 32)),
              // Form fields on the right
              Expanded(
                flex: 3,
                child: _buildFormFields(context),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 32, tablet: 40, desktop: 48)),
          _buildSaveButton(context),
          SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 16, tablet: 20, desktop: 24)),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1000),
        padding: ResponsiveUtils.getResponsivePadding(context),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ResponsiveSectionHeader(
                title: widget.editingItem != null ? 'Edit Your Item' : 'Add New Item',
                subtitle: 'Build your wardrobe with style and organization',
              ),
              SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 24, tablet: 32, desktop: 40)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image section on the left
                  Expanded(
                    flex: 2,
                    child: _buildImageSection(context),
                  ),
                  SizedBox(width: ResponsiveUtils.getResponsiveValue(context, mobile: 16, tablet: 24, desktop: 32)),
                  // Form fields on the right
                  Expanded(
                    flex: 3,
                    child: _buildFormFields(context),
                  ),
                ],
              ),
              SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 32, tablet: 40, desktop: 48)),
              _buildSaveButton(context),
              SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 16, tablet: 20, desktop: 24)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return ResponsiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Photo',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 12, desktop: 16)),
          Container(
            width: double.infinity,
            height: ResponsiveUtils.getResponsiveValue(context, mobile: 200, tablet: 250, desktop: 300),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context),
            ),
            child: _imagePath != null ? _buildImagePreview(context) : _buildImagePlaceholder(context),
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 12, tablet: 16, desktop: 20)),
          ResponsiveWidget(
            mobile: Column(
              children: [
                ResponsiveButton(
                  text: 'Take Photo',
                  icon: Icons.camera_alt,
                  variant: ButtonVariant.secondary,
                  fullWidth: true,
                  onPressed: () => _pickImage(ImageSource.camera),
                ),
                SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 12, desktop: 16)),
                ResponsiveButton(
                  text: 'Choose from Gallery',
                  icon: Icons.photo_library,
                  variant: ButtonVariant.secondary,
                  fullWidth: true,
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),
              ],
            ),
            tablet: Row(
              children: [
                Expanded(
                  child: ResponsiveButton(
                    text: 'Camera',
                    icon: Icons.camera_alt,
                    variant: ButtonVariant.secondary,
                    onPressed: () => _pickImage(ImageSource.camera),
                  ),
                ),
                SizedBox(width: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 12, desktop: 16)),
                Expanded(
                  child: ResponsiveButton(
                    text: 'Gallery',
                    icon: Icons.photo_library,
                    variant: ButtonVariant.secondary,
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),
                ),
              ],
            ),
            desktop: Row(
              children: [
                Expanded(
                  child: ResponsiveButton(
                    text: 'Take Photo',
                    icon: Icons.camera_alt,
                    variant: ButtonVariant.secondary,
                    size: ButtonSize.large,
                    onPressed: () => _pickImage(ImageSource.camera),
                  ),
                ),
                SizedBox(width: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 12, desktop: 16)),
                Expanded(
                  child: ResponsiveButton(
                    text: 'Choose from Gallery',
                    icon: Icons.photo_library,
                    variant: ButtonVariant.secondary,
                    size: ButtonSize.large,
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context),
          child: _imagePath!.startsWith('http')
              ? Image.network(
                  _imagePath!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                )
              : Image.file(
                  File(_imagePath!),
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
        ),
        Positioned(
          top: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 12, desktop: 16),
          right: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 12, desktop: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context),
            ),
            child: IconButton(
              onPressed: () {
                setState(() {
                  _imagePath = null;
                });
              },
              icon: Icon(
                Icons.close,
                color: Colors.white,
                size: ResponsiveUtils.getResponsiveIconSize(context),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder(BuildContext context) {
    return InkWell(
      onTap: () => _showImageSourceDialog(context),
      borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate,
            size: ResponsiveUtils.getResponsiveValue(context, mobile: 48, tablet: 56, desktop: 64),
            color: Colors.grey[400],
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 12, desktop: 16)),
          Text(
            'Add Photo',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 4, tablet: 6, desktop: 8)),
          Text(
            'Tap to select from camera or gallery',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields(BuildContext context) {
    return ResponsiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Item Details',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 16, tablet: 20, desktop: 24)),
          
          // Name Field
          ResponsiveTextField(
            label: 'Item Name',
            hint: 'e.g., Blue Denim Jacket',
            controller: _nameController,
            prefixIcon: Icons.label,
            required: true,
            errorText: _getFieldError('name'),
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 16, tablet: 20, desktop: 24)),
          
          // Category Dropdown
          _buildCategoryDropdown(context),
          SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 16, tablet: 20, desktop: 24)),
          
          // Color Dropdown
          _buildColorDropdown(context),
          SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 16, tablet: 20, desktop: 24)),
          
          // Season Dropdown
          _buildSeasonDropdown(context),
          SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 16, tablet: 20, desktop: 24)),
          
          // Tags Field
          ResponsiveTextField(
            label: 'Tags (Optional)',
            hint: 'e.g., casual, work, waterproof',
            controller: _tagsController,
            prefixIcon: Icons.tag,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category *',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Colors.grey[700],
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 10, desktop: 12)),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context),
            border: Border.all(color: Colors.grey[300]!),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: ResponsiveUtils.getResponsiveValue(context, mobile: 4, tablet: 6, desktop: 8),
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.category,
                color: Colors.grey[400],
                size: ResponsiveUtils.getResponsiveIconSize(context),
              ),
              border: InputBorder.none,
              contentPadding: ResponsiveUtils.getResponsivePadding(context),
            ),
            items: ClothingCategory.all.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(
                  category,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedCategory = value;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildColorDropdown(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color *',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Colors.grey[700],
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 10, desktop: 12)),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context),
            border: Border.all(color: Colors.grey[300]!),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: ResponsiveUtils.getResponsiveValue(context, mobile: 4, tablet: 6, desktop: 8),
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedColor,
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.palette,
                color: Colors.grey[400],
                size: ResponsiveUtils.getResponsiveIconSize(context),
              ),
              border: InputBorder.none,
              contentPadding: ResponsiveUtils.getResponsivePadding(context),
            ),
            items: ClothingColor.colors.map((color) {
              return DropdownMenuItem(
                value: color,
                child: Row(
                  children: [
                    Container(
                      width: ResponsiveUtils.getResponsiveValue(context, mobile: 16, tablet: 18, desktop: 20),
                      height: ResponsiveUtils.getResponsiveValue(context, mobile: 16, tablet: 18, desktop: 20),
                      margin: EdgeInsets.only(
                        right: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 10, desktop: 12),
                      ),
                      decoration: BoxDecoration(
                        color: _getColorFromString(color),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        color,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedColor = value;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSeasonDropdown(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Season *',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Colors.grey[700],
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 10, desktop: 12)),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context),
            border: Border.all(color: Colors.grey[300]!),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: ResponsiveUtils.getResponsiveValue(context, mobile: 4, tablet: 6, desktop: 8),
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedSeason,
            decoration: InputDecoration(
              prefixIcon: Icon(
                _getSeasonIcon(_selectedSeason),
                color: Colors.grey[400],
                size: ResponsiveUtils.getResponsiveIconSize(context),
              ),
              border: InputBorder.none,
              contentPadding: ResponsiveUtils.getResponsivePadding(context),
            ),
            items: Season.all.map((season) {
              return DropdownMenuItem(
                value: season,
                child: Row(
                  children: [
                    Icon(
                      _getSeasonIcon(season),
                      size: ResponsiveUtils.getResponsiveValue(context, mobile: 16, tablet: 18, desktop: 20),
                      color: _getSeasonColor(season),
                    ),
                    SizedBox(width: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 10, desktop: 12)),
                    Text(
                      season,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedSeason = value;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return ResponsiveButton(
      text: _isLoading 
          ? 'Saving...' 
          : (widget.editingItem != null ? 'Update Item' : 'Add to Wardrobe'),
      icon: _isLoading ? null : (widget.editingItem != null ? Icons.update : Icons.add),
      variant: ButtonVariant.gradient,
      size: ResponsiveUtils.getDeviceType(context) == DeviceType.mobile 
          ? ButtonSize.large 
          : ButtonSize.large,
      fullWidth: true,
      loading: _isLoading,
      onPressed: _isLoading ? null : _saveItem,
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: ResponsiveUtils.getResponsiveBorderRadius(context).topLeft,
        ),
      ),
      builder: (context) => Container(
        padding: ResponsiveUtils.getResponsivePadding(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Photo Source',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 16, tablet: 20, desktop: 24)),
            ResponsiveButton(
              text: 'Take Photo',
              icon: Icons.camera_alt,
              variant: ButtonVariant.secondary,
              fullWidth: true,
              onPressed: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 12, tablet: 16, desktop: 20)),
            ResponsiveButton(
              text: 'Choose from Gallery',
              icon: Icons.photo_library,
              variant: ButtonVariant.secondary,
              fullWidth: true,
              onPressed: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 16, tablet: 20, desktop: 24)),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context),
        ),
        title: Text(
          'Tips for Adding Items',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelpTip(context, Icons.camera_alt, 'Photo Tips', 
                'Take clear, well-lit photos with good contrast. Show the full item when possible.'),
            SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 12, tablet: 16, desktop: 20)),
            _buildHelpTip(context, Icons.label, 'Naming', 
                'Use descriptive names like "Blue Denim Jacket" or "Red Silk Blouse".'),
            SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 12, tablet: 16, desktop: 20)),
            _buildHelpTip(context, Icons.tag, 'Tags', 
                'Add tags like "casual", "formal", "waterproof" to help with recommendations.'),
          ],
        ),
        actions: [
          ResponsiveButton(
            text: 'Got it!',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpTip(BuildContext context, IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: ResponsiveUtils.getResponsiveIconSize(context),
          color: AppTheme.primaryColor,
        ),
        SizedBox(width: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 12, desktop: 16)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 4, tablet: 6, desktop: 8)),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _imagePath = image.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_imagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please add a photo'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      final item = ClothingItem(
        id: widget.editingItem?.id,
        name: _nameController.text.trim(),
        category: _selectedCategory,
        color: _selectedColor,
        season: _selectedSeason,
        imagePath: _imagePath!,
        tags: tags,
        createdAt: widget.editingItem?.createdAt ?? DateTime.now(),
      );

      final provider = context.read<WardrobeProvider>();
      
      if (widget.editingItem != null) {
        await provider.updateClothingItem(item);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Item updated successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else {
        await provider.addClothingItem(item);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Item added to your wardrobe!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving item: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String? _getFieldError(String field) {
    // Add field validation logic here if needed
    return null;
  }

  IconData _getSeasonIcon(String season) {
    switch (season) {
      case 'Spring':
        return Icons.local_florist;
      case 'Summer':
        return Icons.wb_sunny;
      case 'Autumn':
        return Icons.emoji_nature;
      case 'Winter':
        return Icons.ac_unit;
      default:
        return Icons.calendar_today;
    }
  }

  Color _getSeasonColor(String season) {
    switch (season) {
      case 'Spring':
        return Colors.green;
      case 'Summer':
        return Colors.orange;
      case 'Autumn':
        return Colors.brown;
      case 'Winter':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color _getColorFromString(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'gray':
      case 'grey':
        return Colors.grey;
      case 'navy':
        return const Color(0xFF000080);
      case 'brown':
        return Colors.brown;
      case 'beige':
        return const Color(0xFFF5F5DC);
      case 'red':
        return Colors.red;
      case 'pink':
        return Colors.pink;
      case 'orange':
        return Colors.orange;
      case 'yellow':
        return Colors.yellow;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'purple':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
