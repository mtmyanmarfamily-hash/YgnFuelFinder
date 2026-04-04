Widget buildFavouriteButton(BuildContext context, String stationId) {
  final provider = Provider.of<FuelProvider>(context);
  final isFav = provider.isFavourite(stationId);

  return IconButton(
    icon: Icon(
      isFav ? Icons.star : Icons.star_border,
      color: isFav ? Colors.orange : Colors.grey,
    ),
    onPressed: () => provider.toggleFavourite(stationId),
  );
}
