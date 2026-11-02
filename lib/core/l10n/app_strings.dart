import '../../features/games/ludo/models/ludo_color.dart';
import '../../features/games/ludo/models/player_seat.dart';

/// Languages the interface is prepared for.
enum AppLanguage {
  en,
  ne;

  static AppLanguage fromName(String? name) {
    for (final value in AppLanguage.values) {
      if (value.name == name) {
        return value;
      }
    }
    return AppLanguage.en;
  }
}

/// Every interface string, in English and Nepali.
///
/// Screens never hardcode labels; they read them from here through
/// `context.strings`. Adding a language means adding an [AppLanguage] value
/// and a branch in [_p]. The Nepali text is a first draft that should be
/// reviewed by a native speaker before release.
class AppStrings {
  const AppStrings(this.language);

  final AppLanguage language;

  String _p(String en, String ne) => language == AppLanguage.ne ? ne : en;

  // General
  String get appName => 'LUDO';
  String get continueLabel => _p('Continue', 'जारी राख्नुहोस्');
  String get cancel => _p('Cancel', 'रद्द गर्नुहोस्');
  String get close => _p('Close', 'बन्द गर्नुहोस्');
  String get save => _p('Save', 'सुरक्षित गर्नुहोस्');
  String get comingSoon => _p('Coming soon', 'छिट्टै आउँदै');
  String get you => _p('You', 'तपाईं');
  String get storageError => _p(
      "Settings couldn't be loaded, so changes made now won't be kept after you close the app.",
      'सेटिङ लोड हुन सकेन, त्यसैले अहिले गरिएका परिवर्तनहरू एप बन्द गरेपछि रहँदैनन्।');

  // Onboarding
  String get onboardingSkip => _p('Skip', 'छोड्नुहोस्');
  String get onboardingNext => _p('Next', 'अर्को');
  String get onboardingStart => _p('Start playing', 'खेल सुरु गर्नुहोस्');
  String get onboardingTitle1 => _p('Welcome to LUDO', 'LUDO मा स्वागत छ');
  String get onboardingBody1 => _p(
      'Classic Ludo, ready to play on this device. No account needed.',
      'क्लासिक लुडो यही डिभाइसमा खेल्न तयार छ। खाता चाहिँदैन।');
  String get onboardingTitle2 => _p('Play your way', 'आफ्नै तरिकाले खेल्नुहोस्');
  String get onboardingBody2 => _p(
      'Take on the computer at three levels, or pass one phone around the table.',
      'तीन तहका कम्प्युटरसँग खेल्नुहोस्, वा एउटै फोन साथीहरूबीच पालैपालो चलाउनुहोस्।');
  String get onboardingTitle3 =>
      _p('Online play is on the way', 'अनलाइन खेल आउँदैछ');
  String get onboardingBody3 => _p(
      'Private rooms with friends, rankings and five more games arrive in later updates.',
      'साथीहरूसँग निजी कोठा, वरियता र थप पाँच खेल पछिका अपडेटमा आउनेछन्।');

  // Navigation
  String get navHome => _p('Home', 'गृह');
  String get navGames => _p('Games', 'खेलहरू');
  String get navFriends => _p('Friends', 'साथीहरू');
  String get navRankings => _p('Rankings', 'वरियता');
  String get navProfile => _p('Profile', 'प्रोफाइल');

  // Home
  String greeting(String name) => _p('Hi, $name', 'नमस्ते, $name');
  String get playingOffline =>
      _p('Playing offline on this device', 'यस डिभाइसमा अफलाइन खेल्दै');
  String get classicLudo => _p('Classic Ludo', 'क्लासिक लुडो');
  String get classicLudoTagline => _p(
      '2 to 4 players. Bring all four tokens home first to win.',
      '२ देखि ४ खेलाडी। चारै गोटी पहिले घर पुर्‍याउने जित्छ।');
  String get quickPlay => _p('Quick play', 'छिटो खेल');
  String quickPlayDetail(int computers, String difficulty) => _p(
      computers == 1
          ? 'You and 1 computer, $difficulty'
          : 'You and $computers computers, $difficulty',
      'तपाईं र $computers कम्प्युटर, $difficulty');
  String get playWithComputer =>
      _p('Play with computer', 'कम्प्युटरसँग खेल्नुहोस्');
  String get playWithFriends =>
      _p('Play with friends', 'साथीहरूसँग खेल्नुहोस्');
  String get vsComputerShort => _p('Vs computer', 'कम्प्युटरसँग');
  String get withFriendsShort => _p('With friends', 'साथीहरूसँग');
  String get yourRecord => _p('Your record', 'तपाईंको रेकर्ड');
  String get statPlayed => _p('Played', 'खेलिएको');
  String get statWins => _p('Wins', 'जित');
  String get statWinRate => _p('Win rate', 'जित दर');
  String get moreGames => _p('More games', 'थप खेलहरू');
  String get recentMatches => _p('Recent matches', 'हालका खेलहरू');
  String get noMatchesYet =>
      _p('Finished matches show up here.', 'सकिएका खेलहरू यहाँ देखिन्छन्।');
  String achievementsProgress(int unlocked, int total) => _p(
      '$unlocked of $total achievements unlocked',
      '$total मध्ये $unlocked उपलब्धि प्राप्त');

  // Games
  String get classicLudoDesc => _p(
      'The board game everyone knows, against the computer or friends on one device.',
      'सबैले चिनेको बोर्ड खेल, कम्प्युटर वा एउटै डिभाइसमा साथीहरूसँग।');
  String get snakeLudo => _p('Snake Ludo', 'स्नेक लुडो');
  String get snakeLudoDesc => _p(
      'Ludo with snakes, shortcuts and bonus squares.',
      'सर्प, छोटो बाटो र बोनस कोठासहितको लुडो।');
  String get chess => _p('Chess', 'चेस');
  String get chessDesc => _p(
      'The full game with clocks, every rule and computer opponents.',
      'घडी, सबै नियम र कम्प्युटर प्रतिद्वन्द्वीसहितको पूरा खेल।');
  String get callBreak => _p('Call Break', 'कल ब्रेक');
  String get callBreakDesc => _p(
      'Four-player trick-taking with spades as trumps.',
      'स्पेड ट्रम्प हुने चार खेलाडीको हात जित्ने खेल।');
  String get teenPatti => _p('Teen Patti', 'तीन पत्ती');
  String get teenPattiDesc => _p(
      'Three-card play with virtual points only. No real money.',
      'भर्चुअल अंक मात्र प्रयोग हुने तीन पत्ती। वास्तविक पैसा छैन।');
  String get marriage => _p('Marriage', 'म्यारिज');
  String get marriageDesc => _p(
      'The Nepali rummy classic, built on a reviewed regional ruleset.',
      'समीक्षा गरिएको क्षेत्रीय नियममा आधारित नेपाली रमी।');
  String get modePassAndPlay => _p('Pass and play', 'पालैपालो खेल');
  String get modeOnlineLater => _p('Online later', 'पछि अनलाइन');
  String get play => _p('Play', 'खेल्नुहोस्');
  String get inDevelopment => _p('In development', 'विकासमा');

  // Setup
  String get setupFriendsHint => _p(
      'Everyone shares this device and takes turns.',
      'सबैले यही डिभाइस पालैपालो प्रयोग गर्छन्।');
  String get players => _p('Players', 'खेलाडी');
  String get yourColor => _p('Your colour', 'तपाईंको रङ');
  String get computerLevel => _p('Computer level', 'कम्प्युटर स्तर');
  String get seats => _p('Seats', 'सिटहरू');
  String get seatPerson => _p('Person', 'व्यक्ति');
  String get seatComputer => _p('Computer', 'कम्प्युटर');
  String computerName(int number) =>
      _p('Computer $number', 'कम्प्युटर $number');
  String playerName(int number) => _p('Player $number', 'खेलाडी $number');
  String get rename => _p('Rename', 'नाम बदल्नुहोस्');
  String get houseRules => _p('House rules', 'घरेलु नियम');
  String get ruleEnterOnOne =>
      _p('Enter on a 1 as well as a 6', '६ का साथै १ मा पनि गोटी निकाल्ने');
  String get ruleThreeSixes => _p('Three sixes in a row end the turn',
      'लगातार तीन छक्काले पालो सकिन्छ');
  String get ruleSafeSquares =>
      _p('Safe squares protect tokens', 'सुरक्षित कोठाले गोटी जोगाउँछ');
  String get ruleCaptureBonus =>
      _p('Capturing earns another roll', 'काट्दा थप पासा पाइन्छ');
  String get ruleFirstFinisher => _p('End when the first player finishes',
      'पहिलो खेलाडी सकिएपछि खेल अन्त्य');
  String get startMatch => _p('Start match', 'खेल सुरु गर्नुहोस्');

  String difficultyName(BotDifficulty difficulty) => switch (difficulty) {
        BotDifficulty.easy => _p('Easy', 'सजिलो'),
        BotDifficulty.medium => _p('Medium', 'मध्यम'),
        BotDifficulty.hard => _p('Hard', 'कठिन'),
      };

  String difficultyHint(BotDifficulty difficulty) => switch (difficulty) {
        BotDifficulty.easy =>
          _p('Picks any legal move.', 'कुनै पनि नियमसम्मत चाल छान्छ।'),
        BotDifficulty.medium => _p(
            'Goes for captures and avoids obvious danger.',
            'काट्ने मौका खोज्छ र स्पष्ट खतरा टार्छ।'),
        BotDifficulty.hard => _p(
            'Weighs every move for progress, safety and risk.',
            'हरेक चाललाई प्रगति, सुरक्षा र जोखिमका आधारमा तौलन्छ।'),
      };

  String colorName(LudoColor color) => switch (color) {
        LudoColor.red => _p('Red', 'रातो'),
        LudoColor.green => _p('Green', 'हरियो'),
        LudoColor.yellow => _p('Yellow', 'पहेँलो'),
        LudoColor.blue => _p('Blue', 'निलो'),
      };

  // Match
  String turnNumber(int number) => _p('Turn $number', 'पालो $number');
  String get yourTurnRoll =>
      _p('Your turn. Tap the dice.', 'तपाईंको पालो। पासा थिच्नुहोस्।');
  String playerTurnRoll(String name) =>
      _p("$name's turn. Tap the dice.", '$name को पालो। पासा थिच्नुहोस्।');
  String pickToken(int roll) =>
      _p('Pick a token to move $roll.', '$roll चाल्न एउटा गोटी छान्नुहोस्।');
  String playerPickToken(String name, int roll) => _p(
      '$name, pick a token to move $roll.',
      '$name, $roll चाल्न एउटा गोटी छान्नुहोस्।');
  String computerPlaying(String name) =>
      _p('$name is playing…', '$name खेल्दैछ…');
  String get rolling => _p('Rolling…', 'पासा फाल्दै…');
  String noticeNoMoves(String name, int roll) =>
      _p('No move for $name with a $roll.', '$name को $roll मा चाल छैन।');
  String noticeSixLimit(String name) => _p(
      "Three sixes. $name's turn is over.", 'तीन छक्का। $name को पालो सकियो।');
  String noticeCapture(String attacker, String victim) =>
      _p('$attacker captured $victim!', '$attacker ले $victim लाई काट्यो!');
  String noticeTokenHome(String name) => _p(
      '$name brought a token home.', '$name ले एउटा गोटी घर पुर्‍यायो।');
  String noticeExtraTurn(String name) =>
      _p('$name rolls again.', '$name फेरि पासा फाल्छ।');
  String noticePlayerFinished(String name, String place) =>
      _p('$name finished $place.', '$name $place भयो।');
  String placement(int place) => switch (place) {
        1 => _p('1st', 'पहिलो'),
        2 => _p('2nd', 'दोस्रो'),
        3 => _p('3rd', 'तेस्रो'),
        _ => _p('${place}th', '$place औं'),
      };
  String tokensHomeShort(int count) => _p('$count/4 home', '$count/4 घर');
  String computerSeatLabel(BotDifficulty difficulty) => _p(
      '${difficultyName(difficulty)} computer',
      '${difficultyName(difficulty)} कम्प्युटर');
  String get personSeatLabel => _p('Player', 'खेलाडी');
  String get leaveTitle => _p('Leave this match?', 'यो खेल छोड्ने?');
  String get leaveBody => _p(
      "The match won't be saved or counted in your stats.",
      'यो खेल सुरक्षित हुँदैन र तथ्याङ्कमा गनिँदैन।');
  String get leave => _p('Leave', 'छोड्नुहोस्');
  String get keepPlaying => _p('Keep playing', 'खेल जारी राख्नुहोस्');
  String get restartTitle => _p('Restart this match?', 'यो खेल फेरि सुरु गर्ने?');
  String get restartBody => _p(
      "The board resets with the same players. This match won't count.",
      'उही खेलाडीसँग बोर्ड फेरि सुरु हुन्छ। यो खेल गनिँदैन।');
  String get restart => _p('Restart', 'फेरि सुरु');
  String get moveLog => _p('Move log', 'चाल विवरण');
  String get moveLogEmpty => _p(
      'Moves appear here once the dice start rolling.',
      'पासा चल्न थालेपछि चालहरू यहाँ देखिन्छन्।');
  String logRolled(String name, int roll) =>
      _p('$name rolled $roll', '$name ले $roll फाल्यो');
  String logEntered(String name) =>
      _p('$name brought a token out', '$name ले गोटी निकाल्यो');
  String logMoved(String name, int steps) =>
      _p('$name moved $steps', '$name ले $steps चाल्यो');
  String logMatchFinished(String name) =>
      _p('$name won the match', '$name ले खेल जित्यो');
  String get soundEffects => _p('Sound effects', 'ध्वनि प्रभाव');
  String get vibration => _p('Vibration', 'कम्पन');
  String get dice => _p('Dice', 'पासा');
  String get tapToRoll => _p('Tap to roll', 'फाल्न थिच्नुहोस्');
  String diceShowing(int value) =>
      _p('Dice showing $value', 'पासामा $value देखिँदैछ');
  String get board => _p('Ludo board', 'लुडो बोर्ड');
  String get matchOptions => _p('Match options', 'खेलका विकल्प');

  // Results
  String get youWon => _p('You won!', 'तपाईंले जित्नुभयो!');
  String playerWins(String name) => _p('$name wins', '$name जित्यो');
  String youPlaced(String place) =>
      _p('You finished $place', 'तपाईं $place हुनुभयो');
  String matchTime(String duration) =>
      _p('Match time $duration', 'खेल समय $duration');
  String get finalStandings => _p('Final standings', 'अन्तिम स्थान');
  String get allTokensHome => _p('All tokens home', 'सबै गोटी घर');
  String tokensHomeLong(int count) =>
      _p('$count of 4 tokens home', '४ मध्ये $count गोटी घर');
  String get statCaptures => _p('Captures', 'काटेको');
  String get statTokensLost => _p('Tokens lost', 'गुमाएको');
  String get statTurns => _p('Turns', 'पालो');
  String get playAgain => _p('Play again', 'फेरि खेल्नुहोस्');
  String get newGame => _p('New game', 'नयाँ खेल');
  String get backHome => _p('Home', 'गृह');

  // Profile
  String get playerId => _p('Player ID', 'खेलाडी आईडी');
  String get storedOnDevice =>
      _p('Saved on this device only', 'यो डिभाइसमा मात्र सुरक्षित');
  String get editName => _p('Edit name', 'नाम बदल्नुहोस्');
  String get displayName => _p('Display name', 'देखिने नाम');
  String get nameEmpty => _p('Enter at least one character.', 'कम्तीमा एउटा अक्षर लेख्नुहोस्।');
  String get avatarColor => _p('Avatar colour', 'अवतारको रङ');
  String get statistics => _p('Statistics', 'तथ्याङ्क');
  String get statBestStreak => _p('Best streak', 'उत्कृष्ट क्रम');
  String get statFastestWin => _p('Fastest win', 'छिटो जित');
  String get statWinsVsHard =>
      _p('Wins against hard', 'कठिनमाथि जित');
  String get achievements => _p('Achievements', 'उपलब्धिहरू');
  String get matchHistory => _p('Match history', 'खेल इतिहास');
  String get account => _p('Account and privacy', 'खाता र गोपनीयता');
  String get accountOfflineNote => _p(
      'Accounts arrive with online play. Until then, your name, stats and history stay on this device.',
      'अनलाइन खेलसँगै खाता आउनेछ। त्यतिन्जेल तपाईंको नाम, तथ्याङ्क र इतिहास यही डिभाइसमा रहन्छ।');
  String get resetStats => _p('Reset statistics', 'तथ्याङ्क मेटाउनुहोस्');
  String get resetStatsTitle =>
      _p('Reset all statistics?', 'सबै तथ्याङ्क मेटाउने?');
  String get resetStatsBody => _p(
      "Wins, history and achievements on this device will be erased. This can't be undone.",
      'यस डिभाइसका जित, इतिहास र उपलब्धि मेटिनेछन्। यो फिर्ता हुँदैन।');
  String get reset => _p('Reset', 'मेटाउनुहोस्');
  String get statsReset => _p('Statistics reset', 'तथ्याङ्क मेटियो');
  String get resultWon => _p('Won', 'जित्यो');
  String resultPlace(String place) => _p('Finished $place', '$place भयो');
  String vsComputers(int count, String difficulty) => _p(
      count == 1
          ? 'Against 1 computer, $difficulty'
          : 'Against $count computers, $difficulty',
      '$count कम्प्युटरविरुद्ध, $difficulty');
  String passAndPlayPlayers(int count) =>
      _p('Pass and play, $count players', 'पालैपालो खेल, $count खेलाडी');

  // Achievements
  String get achFirstMatch => _p('First match', 'पहिलो खेल');
  String get achFirstMatchDesc => _p('Finish a match.', 'एउटा खेल पूरा गर्नुहोस्।');
  String get achFirstWin => _p('First victory', 'पहिलो जित');
  String get achFirstWinDesc => _p('Win a match.', 'एउटा खेल जित्नुहोस्।');
  String get achFiveWins => _p('Five wins', 'पाँच जित');
  String get achFiveWinsDesc => _p('Win 5 matches.', '५ खेल जित्नुहोस्।');
  String get achTenMatches => _p('Regular', 'नियमित खेलाडी');
  String get achTenMatchesDesc =>
      _p('Finish 10 matches.', '१० खेल पूरा गर्नुहोस्।');
  String get achHunter => _p('Hunter', 'शिकारी');
  String get achHunterDesc => _p('Capture 25 tokens.', '२५ गोटी काट्नुहोस्।');
  String get achUntouchable => _p('Untouchable', 'अछुतो');
  String get achUntouchableDesc => _p(
      'Win without losing a single token.', 'एउटा पनि गोटी नगुमाई जित्नुहोस्।');
  String get achBeatHard => _p('Giant slayer', 'बलियोलाई हराउने');
  String get achBeatHardDesc =>
      _p('Beat a hard computer.', 'कठिन कम्प्युटरलाई हराउनुहोस्।');

  // Friends
  String get friendsOnlineTitle =>
      _p('Online friends are on the way', 'अनलाइन साथीहरू आउँदैछन्');
  String get friendsOnlineBody => _p(
      'Friend requests, invites and private rooms arrive with the online update. You can already play together on one device.',
      'साथी अनुरोध, निमन्त्रणा र निजी कोठा अनलाइन अपडेटसँगै आउनेछन्। अहिले पनि एउटै डिभाइसमा सँगै खेल्न सकिन्छ।');
  String get playOnThisDevice =>
      _p('Play on this device', 'यही डिभाइसमा खेल्नुहोस्');

  // Rankings
  String get yourBests =>
      _p('Your bests on this device', 'यस डिभाइसमा तपाईंको उत्कृष्ट');
  String get globalLater => _p(
      'Global rankings for each game arrive with online play.',
      'हरेक खेलको विश्वव्यापी वरियता अनलाइन खेलसँगै आउनेछ।');
  String get noRankingYet => _p('Finish a match to set your first record.',
      'पहिलो रेकर्ड बनाउन एउटा खेल पूरा गर्नुहोस्।');

  // Settings
  String get settings => _p('Settings', 'सेटिङ');
  String get soundAndFeel => _p('Sound and feel', 'ध्वनि र अनुभूति');
  String get display => _p('Display', 'प्रदर्शन');
  String get theme => _p('Theme', 'थिम');
  String get themeDark => _p('Dark', 'गाढा');
  String get themeLight => _p('Light', 'उज्यालो');
  String get themeSystem => _p('System', 'प्रणाली');
  String get reduceMotion => _p('Reduce motion', 'कम एनिमेसन');
  String get reduceMotionHint =>
      _p('Shorter, simpler animations.', 'छोटो र सरल एनिमेसन।');
  String get gameplay => _p('Gameplay', 'खेल');
  String get gameSpeed => _p('Game speed', 'खेलको गति');
  String get speedRelaxed => _p('Relaxed', 'आरामदायी');
  String get speedNormal => _p('Normal', 'सामान्य');
  String get speedFast => _p('Fast', 'छिटो');
  String get autoMove => _p('Move automatically when there is one choice',
      'एउटै विकल्प हुँदा आफैं चाल्ने');
  String get languageLabel => _p('Language', 'भाषा');
  String get nepaliNote => _p('Nepali translation is a first draft.',
      'नेपाली अनुवाद प्रारम्भिक मस्यौदा हो।');
  String get help => _p('Help', 'सहायता');
  String get howToPlay => _p('How to play', 'कसरी खेल्ने');
  String get privacyAndTerms => _p('Privacy and terms', 'गोपनीयता र सर्तहरू');
  String get about => _p('About', 'बारेमा');
  String version(String value) => _p('Version $value', 'संस्करण $value');
  String get licenses => _p('Open-source licences', 'खुला स्रोत इजाजतपत्र');
  String get aboutBody => _p(
      'LUDO is an original board and card game collection. Classic Ludo is available now; more games follow.',
      'LUDO मौलिक बोर्ड र तास खेलहरूको संग्रह हो। क्लासिक लुडो अहिले उपलब्ध छ; थप खेलहरू पछि आउनेछन्।');

  // How to play
  List<(String, String)> get rulesSections => <(String, String)>[
        (
          _p('Goal', 'लक्ष्य'),
          _p('Be the first to move all four of your tokens around the board and into the centre.',
              'आफ्ना चारै गोटी बोर्ड घुमाएर बीचमा पुर्‍याउने पहिलो खेलाडी बन्नुहोस्।'),
        ),
        (
          _p('Getting out', 'गोटी निकाल्ने'),
          _p('Roll a 6 to move a token from your base onto your coloured start square. Every 6 also earns another roll.',
              'आधारबाट आफ्नो रङको सुरु कोठामा गोटी निकाल्न ६ फाल्नुहोस्। हरेक ६ ले थप पासा पनि दिन्छ।'),
        ),
        (
          _p('Moving', 'चाल'),
          _p('Tap a highlighted token to move it by the number rolled. Tokens travel clockwise once around the board, then up their own home column.',
              'फालेको अंक बराबर चाल्न चम्किएको गोटी थिच्नुहोस्। गोटीहरू बोर्डमा एक फन्को घडीको दिशामा घुमेर आफ्नै घर स्तम्भमा जान्छन्।'),
        ),
        (
          _p('Capturing', 'काट्ने'),
          _p("Land exactly on an opponent's token to send it back to their base and earn another roll. Tokens on start squares and star squares are safe.",
              'विपक्षीको गोटीमा ठ्याक्कै पुगे त्यो आधारमा फर्किन्छ र तपाईंले थप पासा पाउनुहुन्छ। सुरु कोठा र तारा कोठामा गोटी सुरक्षित हुन्छ।'),
        ),
        (
          _p('Sixes', 'छक्का'),
          _p('Three sixes in a row end your turn, and the third six cannot be used.',
              'लगातार तीन छक्का आए पालो सकिन्छ र तेस्रो छक्का प्रयोग हुँदैन।'),
        ),
        (
          _p('Finishing', 'घर पुर्‍याउने'),
          _p('A token needs the exact number to reach the centre. Bringing a token home earns another roll. If no token can move, the turn passes.',
              'बीचमा पुग्न ठ्याक्कै अंक चाहिन्छ। गोटी घर पुर्‍याउँदा थप पासा पाइन्छ। कुनै गोटी चल्न नसके पालो अर्कोलाई जान्छ।'),
        ),
      ];

  // Privacy and terms
  List<(String, String)> get privacySections => <(String, String)>[
        (
          _p('What is stored', 'के सुरक्षित हुन्छ'),
          _p('Your display name, avatar colour, settings, statistics and match history are saved only on this device. Nothing is sent to a server.',
              'तपाईंको देखिने नाम, अवतारको रङ, सेटिङ, तथ्याङ्क र खेल इतिहास यही डिभाइसमा मात्र सुरक्षित हुन्छ। केही पनि सर्भरमा पठाइँदैन।'),
        ),
        (
          _p('No accounts or tracking', 'खाता वा ट्र्याकिङ छैन'),
          _p('This version has no sign-in, advertising, analytics or in-app purchases.',
              'यो संस्करणमा साइन-इन, विज्ञापन, एनालिटिक्स वा एपभित्रको खरिद छैन।'),
        ),
        (
          _p('Deleting your data', 'डाटा मेटाउने'),
          _p('Reset statistics from your profile, or uninstall the app to remove everything.',
              'प्रोफाइलबाट तथ्याङ्क मेटाउनुहोस्, वा सबै हटाउन एप अनइन्स्टल गर्नुहोस्।'),
        ),
        (
          _p('Fair play', 'निष्पक्ष खेल'),
          _p('LUDO is for entertainment. It never involves real money, prizes or gambling.',
              'LUDO मनोरञ्जनका लागि हो। यसमा वास्तविक पैसा, पुरस्कार वा जुवा कहिल्यै हुँदैन।'),
        ),
      ];
}
