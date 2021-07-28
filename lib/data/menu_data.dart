class MenuData {
  final int position;
  final String name;
  final String iconImage;

  MenuData(
    this.position, {
    this.name,
    this.iconImage,
  });
}

List<MenuData> planets = [
  MenuData(
    1,
    name: 'Predict Price',
    iconImage: 'images/nha.png',
  ),
  MenuData(
    2,
    name: 'Property Search',
    iconImage: 'images/h1.png',
  ),
  MenuData(
    3,
    name: 'Similar Property',
    iconImage: 'images/similar.png',
  ),
  MenuData(
    4,
    name: 'Price Consult',
    iconImage: 'images/price.png',
  ),
];
