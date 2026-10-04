import 'package:flutter/material.dart';
import 'package:hail_parks_guide/models/map_plant_model.dart';
import 'package:hail_parks_guide/core/widgets/smart_image.dart';
import 'plant_details_page.dart';

class PlantQuickInfoPopup extends StatelessWidget {
  final MapPlant plant;
  final VoidCallback? onWaterTap;

  const PlantQuickInfoPopup({
    super.key,
    required this.plant,
    this.onWaterTap,
  });

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return 'Not available';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  String _formatLastWatered(DateTime? dateTime) {
    if (dateTime == null) return 'Not watered yet';
    final hour = dateTime.hour > 12
        ? dateTime.hour - 12
        : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'pm' : 'am';
    return '$hour:$minute$period - ${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    final needsWater = plant.needsWater();
    final daysLeft = plant.daysUntilWater();

    return Dialog(
      backgroundColor: const Color(0xFFE9E8E1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: SizedBox(
        width: 310,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top bar
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                  const Spacer(),
                  Flexible(
                    child: Text(
                      plant.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PlantDetailsPage(plant: plant),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Plant image — supports both base64 and network URL
              Container(
                width: double.infinity,
                height: 140,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.white,
                ),
                child: plant.imageUrl.isNotEmpty
                    ? SmartImage(
                  imageData: plant.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 140,
                )
                    : const Icon(Icons.local_florist, size: 44),
              ),

              const SizedBox(height: 16),

              // Type shows catalog plant name (Rose, Jasmine etc.)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                    'نوع النبتة: ${plant.catalogPlantName.isNotEmpty ? plant.catalogPlantName : plant.name}',
                    style: const TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 10),

              // Planted By
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                    'زُرعت بواسطة: ${plant.ownerUsername.isNotEmpty ? plant.ownerUsername : 'Unknown'}',
                    style: const TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 10),

              // Planting Date
              Align(
                alignment: Alignment.centerLeft,
                child: Text('تاريخ الزراعة: ${_formatDate(plant.plantedDate)}',
                    style: const TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 10),

              // Last Watered
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                    'آخر مرة تم فيها السقي: ${_formatLastWatered(plant.lastWatered)}',
                    style: const TextStyle(fontSize: 16)),
              ),

              const SizedBox(height: 18),

              // Water button — always visible
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: needsWater ? onWaterTap : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    needsWater ? const Color(0xFF0F6A3B) : Colors.grey[300],
                    foregroundColor:
                    needsWater ? Colors.white : Colors.grey[600],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22)),
                  ),
                  icon: Icon(
                    Icons.water_drop_outlined,
                    color: needsWater ? Colors.white : Colors.grey[500],
                  ),
                  label: Text(
                    needsWater
                        ? 'اسقِ النبتة'
                        : 'يحتاج سقي بعد $daysLeft ${daysLeft == 1 ? 'يوم' : 'أيام'}',
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