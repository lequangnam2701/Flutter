import 'package:flutter/material.dart';
import '../models/place.dart';
import '../services/api_service.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Place> places = [];
  List<Place> popularPlaces = [];
  bool isLoading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      setState(() {
        isLoading = true;
        error = '';
      });

      final allPlaces = await ApiService.getAllPlaces();
      final popular = await ApiService.getPopularPlaces();

      setState(() {
        places = allPlaces;
        popularPlaces = popular;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadData,
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : error.isNotEmpty
                  ? _buildErrorWidget()
                  : _buildContent(),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text('Có lỗi xảy ra', style: TextStyle(fontSize: 18)),
          SizedBox(height: 8),
          Text(error, textAlign: TextAlign.center),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: loadData,
            child: Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.purple, Colors.purpleAccent],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi Guy!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Where are you going next?',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 20),
                  // Search Bar
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search your destination',
                        border: InputBorder.none,
                        icon: Icon(Icons.search, color: Colors.grey),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Category Buttons
                  Row(
                    children: [
                      _buildCategoryButton('Hotels', Colors.orange, Icons.hotel),
                      SizedBox(width: 12),
                      _buildCategoryButton('Flights', Colors.green, Icons.flight),
                      SizedBox(width: 12),
                      _buildCategoryButton('All', Colors.blue, Icons.explore),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // Popular Destinations Title
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Popular Destinations',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        
        // Popular Places Grid
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final place = popularPlaces.isNotEmpty 
                    ? popularPlaces[index % popularPlaces.length]
                    : _getDummyPlace(index);
                return _buildPlaceCard(place);
              },
              childCount: popularPlaces.isNotEmpty ? popularPlaces.length : 4,
            ),
          ),
        ),
        
        // Bottom Spacing
        SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  Widget _buildCategoryButton(String title, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceCard(Place place) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            // Background Image
            Container(
              width: double.infinity,
              height: double.infinity,
              child: Image.network(
                place.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Icon(Icons.image, size: 50, color: Colors.grey),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            
            // Heart Icon
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.favorite_border,
                  color: Colors.red,
                  size: 20,
                ),
              ),
            ),
            
            // Place Info
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    place.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.white70,
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          place.location,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Place _getDummyPlace(int index) {
    final dummyPlaces = [
      Place(
        id: 1,
        name: 'Ha Long Bay',
        description: 'Beautiful bay in Vietnam',
        imageUrl: 'https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=400',
        location: 'Vietnam',
        rating: 4.8,
        isPopular: true,
      ),
      Place(
        id: 2,
        name: 'Hoi An',
        description: 'Ancient town in Vietnam',
        imageUrl: 'https://images.unsplash.com/photo-1557804506-669a67965ba0?w=400',
        location: 'Vietnam',
        rating: 4.7,
        isPopular: true,
      ),
      Place(
        id: 3,
        name: 'Sapa',
        description: 'Mountain town with rice terraces',
        imageUrl: 'https://images.unsplash.com/photo-1583417267826-aebc4d1542e1?w=400',
        location: 'Vietnam',
        rating: 4.6,
        isPopular: true,
      ),
      Place(
        id: 4,
        name: 'Da Nang',
        description: 'Coastal city with beautiful beaches',
        imageUrl: 'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=400',
        location: 'Vietnam',
        rating: 4.5,
        isPopular: true,
      ),
    ];
    return dummyPlaces[index % dummyPlaces.length];
  }
}