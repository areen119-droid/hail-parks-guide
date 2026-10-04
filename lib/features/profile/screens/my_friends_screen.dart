import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hail_parks_guide/core/constants/app_color.dart';
import 'package:hail_parks_guide/core/widgets/curved_header.dart';
import 'package:hail_parks_guide/models/friend_model.dart';
import 'package:hail_parks_guide/providers/friends_provider.dart';

class MyFriendsScreen extends StatefulWidget {
  final String userId;

  const MyFriendsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _MyFriendsScreenState createState() => _MyFriendsScreenState();
}

class _MyFriendsScreenState extends State<MyFriendsScreen> {
  List<FriendModel> _friends = [];
  List<FriendModel> _filteredFriends = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFriends();
    _searchController.addListener(_filterFriends);
  }

  Future<void> _loadFriends() async {
    setState(() => _isLoading = true);

    try {
      final friendProvider = Provider.of<FriendProvider>(context, listen: false);
      _friends = await friendProvider.getUserFriends(widget.userId);
      _filteredFriends = _friends;
    } catch (e) {
      print('Error loading friends: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterFriends() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFriends = _friends.where((friend) {
        return friend.name.toLowerCase().contains(query) ||
            friend.username.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: Stack(
        children: [
          // Curved Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CurvedHeader(height: 180),
          ),

          Column(
            children: [
              SizedBox(height: 50),

              // App Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: AppColors.whiteColor),
                      onPressed: () => Navigator.pop(context),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'أصدقائي',
                      style: TextStyle(
                        color: AppColors.whiteColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.baseGreyColor.withOpacity(0.3),
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      hintText: 'بحث عن أصدقاء...',
                      hintStyle: TextStyle(color: AppColors.mediumGrey),
                      prefixIcon: Icon(Icons.search, color: AppColors.baseDarkGreenColor),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ),

              // Friends List
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator(color: AppColors.baseDarkGreenColor))
                    : _filteredFriends.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 80, color: AppColors.softGreen),
                      SizedBox(height: 16),
                      Text(
                        _searchController.text.isEmpty
                            ? 'لا يوجد أصدقاء بعد'
                            : 'لا يوجد أصدقاء مطابقين',
                        style: TextStyle(fontSize: 16, color: AppColors.mediumGrey),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredFriends.length,
                  itemBuilder: (context, index) {
                    final friend = _filteredFriends[index];
                    return _buildFriendCard(friend);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFriendCard(FriendModel friend) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColors.whiteColor,
      child: ListTile(
        contentPadding: EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: AppColors.softMint,
          backgroundImage: friend.profileImageUrl != null
              ? CachedNetworkImageProvider(friend.profileImageUrl!)
              : null,
          child: friend.profileImageUrl == null
              ? Icon(Icons.person, size: 30, color: AppColors.baseDarkGreenColor)
              : null,
        ),
        title: Text(
          friend.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.baseBlackColor,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '@${friend.username}',
              style: TextStyle(color: AppColors.mediumGrey),
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.eco, size: 14, color: AppColors.baseDarkGreenColor),
                SizedBox(width: 4),
                Text(
                  '${friend.points} نقطة',
                  style: TextStyle(color: AppColors.baseBlackColor),
                ),
              ],
            ),
          ],
        ),
        // TODO: open the friend's profile once ProfileScreen supports other users.
      ),
    );
  }
}