import 'package:mohaeng_app_service/core/mohaeng/m_images.dart';

enum CompanionType {
  family,
  friends,
  couple,
  spouse,
  children,
  solo,
  parents,
  teacher,
  students,
  colleagues,
  seniors;

  String get label => switch (this) {
    CompanionType.family => '가족',
    CompanionType.friends => '친구',
    CompanionType.couple => '연인',
    CompanionType.spouse => '배우자',
    CompanionType.children => '아이',
    CompanionType.solo => '혼자',
    CompanionType.parents => '부모님',
    CompanionType.teacher => '선생님',
    CompanionType.students => '학생',
    CompanionType.colleagues => '직장 동료',
    CompanionType.seniors => '어르신',
  };

  List<String> get fallbackEmojis => switch (this) {
    CompanionType.family => const ['👨‍👩‍👧‍👦'],
    CompanionType.friends => const ['🧑‍🤝‍🧑'],
    CompanionType.couple => const ['👫'],
    CompanionType.spouse => const ['💍'],
    CompanionType.children => const ['👶'],
    CompanionType.solo => const ['🚶‍♂️'],
    CompanionType.parents => const ['🚶‍♂️', '🚶‍♀️'],
    CompanionType.teacher => const ['🧑‍🏫'],
    CompanionType.students => const ['🧑‍🎓'],
    CompanionType.colleagues => const ['👨‍💼'],
    CompanionType.seniors => const ['🧓'],
  };

  List<String> get imagePaths => switch (this) {
    CompanionType.family => const ['assets/images/companion/family.png'],
    CompanionType.friends => const [
      'assets/images/companion/alone.png',
      'assets/images/companion/friend.png',
    ],
    CompanionType.couple => const ['assets/images/companion/couple.png'],
    CompanionType.spouse => const ['assets/images/companion/couple.png'],
    CompanionType.children => const ['assets/images/companion/baby.png'],
    CompanionType.solo => const ['assets/images/companion/alone.png'],
    CompanionType.parents => const [
      'assets/images/companion/alone.png',
      'assets/images/companion/parent.png',
    ],
    CompanionType.teacher => const ['assets/images/companion/worker.png'],
    CompanionType.students => const [
      'assets/images/companion/alone.png',
      'assets/images/companion/friend.png',
    ],
    CompanionType.colleagues => const ['assets/images/companion/worker.png'],
    CompanionType.seniors => const ['assets/images/companion/parent.png'],
  };

  String get apiValue => switch (this) {
    CompanionType.family => 'FAMILY',
    CompanionType.friends => 'FRIENDS',
    CompanionType.couple => 'COUPLE',
    CompanionType.spouse => 'SPOUSE',
    CompanionType.children => 'CHILDREN',
    CompanionType.solo => 'SOLO',
    CompanionType.parents => 'PARENTS',
    CompanionType.teacher => 'TEACHER',
    CompanionType.students => 'STUDENTS',
    CompanionType.colleagues => 'COLLEAGUES',
    CompanionType.seniors => 'SENIORS',
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
    TravelConcept.family => '가족여행',
    TravelConcept.healing => '힐링',
    TravelConcept.nature => '자연',
    TravelConcept.shopping => '쇼핑',
    TravelConcept.city => '도시여행',
    TravelConcept.photo => '사진·인생샷',
    TravelConcept.unique => '이색여행',
    TravelConcept.honeymoon => '신혼여행',
    TravelConcept.cultureArt => '문화·예술',
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
    TravelConcept.food => 'FOOD_TOUR',
    TravelConcept.family => 'FAMILY_TRIP',
    TravelConcept.healing => 'HEALING',
    TravelConcept.nature => 'NATURE',
    TravelConcept.shopping => 'SHOPPING',
    TravelConcept.city => 'CITY_TRIP',
    TravelConcept.photo => 'PHOTO_SPOTS',
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
