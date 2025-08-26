class OnboardingData {
  final String title;
  final String description;
  final String image;

  OnboardingData({
    required this.title,
    required this.description,
    required this.image,
  });
}

List<OnboardingData> onboardingPages = [
  OnboardingData(
    title: "Welcome to Warehouse Management",
    description: "Streamline your inventory management with our comprehensive warehouse solution.",
    image: "assets/images/welcome_page/1.png",
  ),
  OnboardingData(
    title: "Smart Inventory Tracking",
    description: "Track your products in real-time with advanced barcode scanning and inventory management.",
    image: "assets/images/welcome_page/2.png",
  ),
  OnboardingData(
    title: "Efficient Operations",
    description: "Optimize your warehouse operations with automated workflows and smart organization.",
    image: "assets/images/welcome_page/3.png",
  ),
  OnboardingData(
    title: "Ease of Use",
    description: "An intuitive interface that requires no special skills allows users to quickly add, edit, and manage products effortlessly.",
    image: "assets/images/welcome_page/4.png",
  ),
];
