enum ItemType {
  timeFreezer,
  magnifyingGlass,
  luckyCharm,
  priceFreeze,
  secondChance,
}

class ShopItem {
  final ItemType type;
  final String name;
  final String description;
  final int price;
  final String emoji;

  const ShopItem({
    required this.type,
    required this.name,
    required this.description,
    required this.price,
    required this.emoji,
  });

  static List<ShopItem> get allItems => [
        const ShopItem(
          type: ItemType.timeFreezer,
          name: '시간 정지',
          description: '경매 타이머를 10초간 멈춥니다',
          price: 20000000,
          emoji: '🧊',
        ),
        const ShopItem(
          type: ItemType.magnifyingGlass,
          name: '돋보기',
          description: '현재 경쟁자 수를 확인합니다',
          price: 10000000,
          emoji: '🔍',
        ),
        const ShopItem(
          type: ItemType.luckyCharm,
          name: '행운의 참',
          description: '낙찰 확률을 10% 높입니다',
          price: 50000000,
          emoji: '🍀',
        ),
        const ShopItem(
          type: ItemType.priceFreeze,
          name: '가격 동결',
          description: 'AI 경쟁자의 입찰가를 낮춥니다',
          price: 30000000,
          emoji: '❄️',
        ),
        const ShopItem(
          type: ItemType.secondChance,
          name: '재도전권',
          description: '유찰 시 한 번 더 기회를 얻습니다',
          price: 100000000,
          emoji: '🔄',
        ),
      ];

  static ShopItem fromType(ItemType type) {
    return allItems.firstWhere((item) => item.type == type);
  }
}
