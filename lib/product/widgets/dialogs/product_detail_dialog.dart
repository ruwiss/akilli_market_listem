import 'package:akilli_market_listem/product/models/product.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme_constants.dart';
import '../../../core/theme/color_scheme.dart';
import '../../../viewmodel/product_search_view_model.dart';
import '../../../viewmodel/shopping_list_view_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/api_constants.dart';

enum TimeRange {
  week('1 Hafta'),
  month('1 Ay'),
  year('1 Yıl');

  final String label;
  const TimeRange(this.label);
}

class _PriceHistoryChart extends StatefulWidget {
  final List<PriceHistory> priceHistory;

  const _PriceHistoryChart({required this.priceHistory});

  @override
  State<_PriceHistoryChart> createState() => _PriceHistoryChartState();
}

class _PriceHistoryChartState extends State<_PriceHistoryChart> {
  TimeRange _selectedRange = TimeRange.month;
  late List<PriceHistory> _filteredHistory;

  @override
  void initState() {
    super.initState();
    _updateFilteredHistory();
  }

  void _updateFilteredHistory() {
    final now = DateTime.now();

    // Önce tüm geçmiş verileri tarihe göre sırala (eskiden yeniye)
    final sortedHistory = List<PriceHistory>.from(widget.priceHistory)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Seçili aralığa göre filtrele
    _filteredHistory = sortedHistory.where((item) {
      switch (_selectedRange) {
        case TimeRange.week:
          return now.difference(item.date).inDays <= 7;
        case TimeRange.month:
          return now.difference(item.date).inDays <= 30;
        case TimeRange.year:
          return now.difference(item.date).inDays <= 365;
      }
    }).toList();

    // Eğer aynı güne ait birden fazla veri varsa, en son fiyatı al
    final Map<String, PriceHistory> dailyPrices = {};
    for (var item in _filteredHistory) {
      final dateKey = '${item.date.year}-${item.date.month}-${item.date.day}';
      dailyPrices[dateKey] = item;
    }

    // Son fiyatları tekrar tarihe göre sırala
    _filteredHistory = dailyPrices.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  void _onRangeChanged(TimeRange range) {
    setState(() {
      _selectedRange = range;
      _updateFilteredHistory();
    });
  }

  double _calculatePriceInterval() {
    if (_filteredHistory.isEmpty) return 1.0;
    double minPrice = _filteredHistory[0].price;
    double maxPrice = _filteredHistory[0].price;
    for (var price in _filteredHistory) {
      if (price.price < minPrice) minPrice = price.price;
      if (price.price > maxPrice) maxPrice = price.price;
    }

    double range = maxPrice - minPrice;
    if (range < 0.1) return 0.1; // Çok yakın değerler için minimum aralık

    // Fiyat aralığına göre uygun interval seç
    if (range <= 1) return 0.2;
    if (range <= 5) return 1.0;
    if (range <= 10) return 2.0;
    if (range <= 50) return 10.0;
    if (range <= 100) return 20.0;
    if (range <= 500) return 100.0;
    if (range <= 1000) return 200.0;
    return (range / 5).ceil().toDouble();
  }

  double _calculateDateInterval() {
    if (_filteredHistory.isEmpty) return 1.0;
    // Veri sayısına göre gösterilecek tarih sayısını ayarla
    if (_filteredHistory.length <= 5) return 1.0;
    if (_filteredHistory.length <= 10) return 2.0;
    if (_filteredHistory.length <= 20) return 4.0;
    return (_filteredHistory.length / 5).ceil().toDouble();
  }

  String _formatDate(DateTime date) {
    final months = [
      'Oca',
      'Şub',
      'Mar',
      'Nis',
      'May',
      'Haz',
      'Tem',
      'Ağu',
      'Eyl',
      'Eki',
      'Kas',
      'Ara'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  double _calculateMinY() {
    if (_filteredHistory.isEmpty) return 0;
    double minPrice = _filteredHistory[0].price;
    for (var price in _filteredHistory) {
      if (price.price < minPrice) minPrice = price.price;
    }
    // Minimum değeri biraz daha düşük göster
    return (minPrice - (minPrice * 0.02)).floorToDouble();
  }

  double _calculateMaxY() {
    if (_filteredHistory.isEmpty) return 0;
    double maxPrice = _filteredHistory[0].price;
    for (var price in _filteredHistory) {
      if (price.price > maxPrice) maxPrice = price.price;
    }
    // Maksimum değeri biraz daha yüksek göster
    return (maxPrice + (maxPrice * 0.02)).ceilToDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: TimeRange.values.map((range) {
              final isSelected = range == _selectedRange;
              return Padding(
                padding:
                    const EdgeInsets.only(right: AppThemeConstants.spacingS),
                child: FilterChip(
                  label: Text(range.label),
                  selected: isSelected,
                  onSelected: (_) => _onRangeChanged(range),
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  selectedColor:
                      Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  labelStyle: AppThemeConstants.bodySmall.copyWith(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context)
                            .colorScheme
                            .outline
                            .withOpacity(0.3),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppThemeConstants.spacingM),
        if (_filteredHistory.isEmpty || _filteredHistory.length < 3)
          Container(
            padding: const EdgeInsets.all(AppThemeConstants.spacingL),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppThemeConstants.radiusM),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.timeline_outlined,
                  size: 48,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                ),
                const SizedBox(height: AppThemeConstants.spacingM),
                Text(
                  _selectedRange == TimeRange.week
                      ? 'Son 1 haftaya ait yeterli fiyat verisi bulunamadı'
                      : _selectedRange == TimeRange.month
                          ? 'Son 1 aya ait yeterli fiyat verisi bulunamadı'
                          : 'Son 1 yıla ait yeterli fiyat verisi bulunamadı',
                  textAlign: TextAlign.center,
                  style: AppThemeConstants.bodyMedium.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _calculatePriceInterval(),
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: Theme.of(context).colorScheme.surface,
                    tooltipRoundedRadius: 8,
                    tooltipBorder: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withOpacity(0.1),
                    ),
                    tooltipPadding: const EdgeInsets.symmetric(
                      horizontal: AppThemeConstants.spacingM,
                      vertical: AppThemeConstants.spacingS,
                    ),
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final date = _filteredHistory[spot.x.toInt()].date;
                        return LineTooltipItem(
                          '${_formatDate(date)}\n${spot.y.toStringAsFixed(2)} ₺',
                          AppThemeConstants.bodySmall.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).toList();
                    },
                  ),
                  handleBuiltInTouches: true,
                  touchSpotThreshold: 20,
                ),
                clipData: FlClipData.all(),
                minX: 0,
                maxX: (_filteredHistory.length - 1).toDouble(),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 65,
                      interval: _calculatePriceInterval(),
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            '${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1)} ₺',
                            style: AppThemeConstants.bodySmall
                                .copyWith(fontSize: 10),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: _calculateDateInterval(),
                      reservedSize: 35,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 &&
                            value.toInt() < _filteredHistory.length) {
                          final date = _filteredHistory[value.toInt()].date;
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            angle: 45,
                            child: Text(
                              _formatDate(date),
                              style: AppThemeConstants.bodySmall
                                  .copyWith(fontSize: 10),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withOpacity(0.2),
                    ),
                    left: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withOpacity(0.2),
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      _filteredHistory.length,
                      (index) => FlSpot(
                        index.toDouble(),
                        _filteredHistory[index].price,
                      ),
                    ),
                    isCurved: true,
                    color: AppColorScheme.primaryColor,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 3,
                          color: AppColorScheme.primaryColor,
                          strokeWidth: 1,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColorScheme.primaryColor.withOpacity(0.1),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColorScheme.primaryColor.withOpacity(0.2),
                          AppColorScheme.primaryColor.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ],
                minY: _calculateMinY(),
                maxY: _calculateMaxY(),
              ),
            ),
          ),
      ],
    );
  }
}

class ProductDetailDialog extends StatelessWidget {
  final ProductDetail productDetail;
  final String productImage;

  const ProductDetailDialog({
    super.key,
    required this.productDetail,
    required this.productImage,
  });

  @override
  Widget build(BuildContext context) {
    final productSearchViewModel = Provider.of<ProductSearchViewModel>(context);
    final shoppingListViewModel = Provider.of<ShoppingListViewModel>(context);

    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppThemeConstants.radiusL),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, productDetail),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppThemeConstants.spacingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (productDetail.description != null) ...[
                      Text(
                        'Açıklama',
                        style: AppThemeConstants.titleMedium,
                      ),
                      const SizedBox(height: AppThemeConstants.spacingS),
                      Text(
                        productDetail.description!,
                        style: AppThemeConstants.bodyMedium,
                      ),
                      const SizedBox(height: AppThemeConstants.spacingL),
                    ],
                    if (productDetail.specs.isNotEmpty) ...[
                      ...productDetail.specs
                          .map((group) => _buildSpecGroup(context, group)),
                      const SizedBox(height: AppThemeConstants.spacingL),
                    ],
                    Text(
                      'Fiyat Geçmişi',
                      style: AppThemeConstants.titleMedium,
                    ),
                    const SizedBox(height: AppThemeConstants.spacingS),
                    _PriceHistoryChart(
                        priceHistory: productDetail.priceHistory),
                    const SizedBox(height: AppThemeConstants.spacingL),
                    if (productDetail.offers.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.all(AppThemeConstants.spacingM),
                        child: Text(
                          'Diğer Market Fiyatları',
                          style: AppThemeConstants.titleMedium,
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: productDetail.offers.length,
                        itemBuilder: (context, index) {
                          final offer = productDetail.offers[index];
                          return ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(
                                    AppThemeConstants.radiusM),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    AppThemeConstants.radiusM),
                                child: CachedNetworkImage(
                                  imageUrl: ApiConstants.getMerchantLogoUrl(
                                      offer.merchantLogo),
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.1),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.1),
                                    child: Icon(
                                      Icons.store,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              offer.merchantName,
                              style: AppThemeConstants.titleSmall,
                            ),
                            subtitle: Text(
                              '${offer.unitPrice.toStringAsFixed(2)} ₺/birim',
                              style: AppThemeConstants.bodySmall.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.6),
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${offer.price.toStringAsFixed(2)} ₺',
                                  style: AppThemeConstants.titleSmall.copyWith(
                                    color: AppColorScheme.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(
                                    width: AppThemeConstants.spacingS),
                                IconButton(
                                  onPressed: () {
                                    // Ana ürünün bilgilerini al
                                    final searchViewModel =
                                        context.read<ProductSearchViewModel>();
                                    final products = searchViewModel.products;

                                    // Ana ürünü bul
                                    Product? mainProduct;
                                    try {
                                      mainProduct = products.firstWhere(
                                        (p) => p.id == productDetail.id,
                                      );
                                    } catch (e) {
                                      // Ürün bulunamadıysa detay bilgilerinden yeni bir ürün oluştur
                                      mainProduct = Product(
                                        id: productDetail.id,
                                        name: productDetail.name,
                                        brand: productDetail.specs
                                            .expand((group) => group.items)
                                            .firstWhere(
                                              (item) =>
                                                  item.name.toLowerCase() ==
                                                  'marka',
                                              orElse: () => SpecItem(
                                                  name: 'Marka', value: ''),
                                            )
                                            .value,
                                        price: offer.price,
                                        unitPrice: offer.unitPrice,
                                        quantity: productDetail.specs
                                            .expand((group) => group.items)
                                            .firstWhere(
                                              (item) => item.name
                                                  .toLowerCase()
                                                  .contains('miktar'),
                                              orElse: () => SpecItem(
                                                  name: 'Miktar', value: ''),
                                            )
                                            .value,
                                        unit: productDetail.specs
                                            .expand((group) => group.items)
                                            .firstWhere(
                                              (item) => item.name
                                                  .toLowerCase()
                                                  .contains('birim'),
                                              orElse: () => SpecItem(
                                                  name: 'Birim', value: ''),
                                            )
                                            .value,
                                        merchantId: offer.merchantId,
                                        merchantLogo:
                                            '/logo.php?id=${offer.merchantId}',
                                        image: productImage,
                                        url: '',
                                      );
                                    }

                                    // Yeni ürün oluştur
                                    final product = Product(
                                      id: productDetail.id,
                                      name: productDetail.name,
                                      brand: mainProduct.brand,
                                      price: offer.price,
                                      unitPrice: offer.unitPrice,
                                      quantity: mainProduct.quantity,
                                      unit: mainProduct.unit,
                                      merchantId: offer.merchantId,
                                      merchantLogo:
                                          '/logo.php?id=${offer.merchantId}',
                                      image: productImage,
                                      url: mainProduct.url,
                                    );

                                    context
                                        .read<ShoppingListViewModel>()
                                        .addProductToList(
                                          context,
                                          product,
                                        );

                                    Navigator.of(context).pop();
                                  },
                                  icon: Icon(
                                    Icons.add_shopping_cart_outlined,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  tooltip: 'Listeye Ekle',
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ProductDetail product) {
    return Container(
      padding: const EdgeInsets.all(AppThemeConstants.spacingM),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppThemeConstants.radiusL),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              product.name,
              style: AppThemeConstants.titleMedium.copyWith(
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecGroup(BuildContext context, SpecGroup group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          group.group,
          style: AppThemeConstants.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppThemeConstants.spacingXS),
        ...group.items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(
              left: AppThemeConstants.spacingS,
              bottom: AppThemeConstants.spacingXS,
            ),
            child: Row(
              children: [
                Text(
                  '${item.name}: ',
                  style: AppThemeConstants.bodySmall.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
                ),
                Text(
                  item.value,
                  style: AppThemeConstants.bodySmall,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppThemeConstants.spacingS),
      ],
    );
  }
}
