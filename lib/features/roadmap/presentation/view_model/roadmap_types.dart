import 'package:mohaeng_app_service/core/mohaeng/m_images.dart';

enum CompanionType {
  solo,
  parents,
  friend,
  lover,
  child,
  family,
  coworker;

  String get label => switch (this) {
    CompanionType.solo => '혼자',
    CompanionType.parents => '부모님',
    CompanionType.friend => '친구',
    CompanionType.lover => '연인',
    CompanionType.child => '아이',
    CompanionType.family => '가족',
    CompanionType.coworker => '직장 동료',
  };

  List<String> get fallbackEmojis => switch (this) {
    CompanionType.solo => const ['🚶‍♂️'],
    CompanionType.parents => const ['🚶‍♂️', '🚶‍♀️'],
    CompanionType.friend => const ['🚶‍♂️', '🚶‍♂️'],
    CompanionType.lover => const ['👫'],
    CompanionType.child => const ['👶'],
    CompanionType.family => const ['👨‍👩‍👧‍👦'],
    CompanionType.coworker => const ['👨‍💼'],
  };

  List<String> get imagePaths => switch (this) {
    CompanionType.solo => const ['assets/images/companion/alone.png'],
    CompanionType.parents => const [
      'assets/images/companion/alone.png',
      'assets/images/companion/parent.png',
    ],
    CompanionType.friend => const [
      'assets/images/companion/alone.png',
      'assets/images/companion/friend.png',
    ],
    CompanionType.lover => const ['assets/images/companion/couple.png'],
    CompanionType.child => const ['assets/images/companion/baby.png'],
    CompanionType.family => const ['assets/images/companion/family.png'],
    CompanionType.coworker => const ['assets/images/companion/worker.png'],
  };

  String get apiValue => switch (this) {
    CompanionType.solo => 'SOLO',
    CompanionType.parents => 'PARENTS',
    CompanionType.friend => 'FRIEND',
    CompanionType.lover => 'LOVER',
    CompanionType.child => 'CHILD',
    CompanionType.family => 'FAMILY',
    CompanionType.coworker => 'COWORKER',
  };
}

enum TravelConcept {
  sightseeing,
  food,
  family,
  healing,
  nature,
  shopping,
  city,
  photo,
  unique,
  honeymoon,
  cultureArt,
  activity;

  String get label => switch (this) {
    TravelConcept.sightseeing => '관광',
    TravelConcept.food => '먹방',
    TravelConcept.family => '가족 여행',
    TravelConcept.healing => '힐링',
    TravelConcept.nature => '자연',
    TravelConcept.shopping => '쇼핑',
    TravelConcept.city => '도시 여행',
    TravelConcept.photo => '사진 인생샷',
    TravelConcept.unique => '이색 여행',
    TravelConcept.honeymoon => '신혼 여행',
    TravelConcept.cultureArt => '문화, 예술',
    TravelConcept.activity => '액티비티',
  };

  String get fallbackEmoji => switch (this) {
    TravelConcept.sightseeing => '✈️',
    TravelConcept.food => '🍽️',
    TravelConcept.family => '👨‍👩‍👧‍👦',
    TravelConcept.healing => '🛁',
    TravelConcept.nature => '🏕️',
    TravelConcept.shopping => '🛍️',
    TravelConcept.city => '🏙️',
    TravelConcept.photo => '📷',
    TravelConcept.unique => '🧩',
    TravelConcept.honeymoon => '💞',
    TravelConcept.cultureArt => '🎨',
    TravelConcept.activity => '🧗‍♂️',
  };

  String get imagePath => switch (this) {
    TravelConcept.sightseeing => MImages.conceptSightseeing,
    TravelConcept.food => MImages.conceptFood,
    TravelConcept.family => MImages.conceptFamily,
    TravelConcept.healing => MImages.conceptHealing,
    TravelConcept.nature => MImages.conceptNature,
    TravelConcept.shopping => MImages.conceptShopping,
    TravelConcept.city => MImages.conceptCity,
    TravelConcept.photo => MImages.conceptPhoto,
    TravelConcept.unique => MImages.conceptUnique,
    TravelConcept.honeymoon => MImages.conceptHoneymoon,
    TravelConcept.cultureArt => MImages.conceptCultureArt,
    TravelConcept.activity => MImages.conceptActivity,
  };

  String get apiValue => switch (this) {
    TravelConcept.sightseeing => 'SIGHTSEEING',
    TravelConcept.food => 'FOOD',
    TravelConcept.family => 'FAMILY',
    TravelConcept.healing => 'HEALING',
    TravelConcept.nature => 'NATURE',
    TravelConcept.shopping => 'SHOPPING',
    TravelConcept.city => 'CITY',
    TravelConcept.photo => 'PHOTO',
    TravelConcept.unique => 'UNIQUE_TRIP',
    TravelConcept.honeymoon => 'HONEYMOON',
    TravelConcept.cultureArt => 'CULTURE_ART',
    TravelConcept.activity => 'ACTIVITY',
  };
}

enum TravelStyleQuestion {
  pace,
  planning,
  destination,
  activity,
  priority,
}

enum PacePreference {
  DENSE,
  RELAXED;

  String get label => switch (this) {
    PacePreference.DENSE => '빡빡하게',
    PacePreference.RELAXED => '널널하게',
  };

  String get apiValue => name;
}

enum PlanningPreference {
  PLANNED,
  SPONTANEOUS;

  String get label => switch (this) {
    PlanningPreference.PLANNED => '계획형',
    PlanningPreference.SPONTANEOUS => '즉흥형',
  };

  String get apiValue => name;
}

enum DestinationPreference {
  TOURIST_SPOTS,
  LOCAL_EXPERIENCE;

  String get label => switch (this) {
    DestinationPreference.TOURIST_SPOTS => '관광지 위주',
    DestinationPreference.LOCAL_EXPERIENCE => '로컬 위주',
  };

  String get apiValue => name;
}

enum ActivityPreference {
  ACTIVE,
  REST_FOCUSED;

  String get label => switch (this) {
    ActivityPreference.ACTIVE => '활동 중심',
    ActivityPreference.REST_FOCUSED => '휴식 중심',
  };

  String get apiValue => name;
}

enum PriorityPreference {
  EFFICIENCY,
  EMOTIONAL;

  String get label => switch (this) {
    PriorityPreference.EFFICIENCY => '효율 우선',
    PriorityPreference.EMOTIONAL => '감성 우선',
  };

  String get apiValue => name;
}

enum BudgetRange {
  LOW,
  MID,
  HIGH,
  LUXURY;

  String get label => switch (this) {
    BudgetRange.LOW => '가성비 / 저예산',
    BudgetRange.MID => '기본 / 적당한',
    BudgetRange.HIGH => '프리미엄',
    BudgetRange.LUXURY => '럭셔리',
  };

  String get apiValue => name;
}
