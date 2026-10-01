import 'package:sqflite/sqflite.dart';

import '../../domain/entities/app_metadata.dart';

/// Seeds the database with a small, representative sample of Philippine
/// legal texts for demonstration purposes.
///
/// IMPORTANT: The article texts below reproduce (or closely summarize)
/// publicly available Philippine government legal texts, which as
/// government works are not subject to copyright. They are provided here
/// as *sample* content for this offline-reference MVP and have **not**
/// been independently verified against the Official Gazette for this
/// build. See `docs/data-ingestion-plan.md` for how a verified, versioned
/// dataset would be ingested for production use.
class SeedData {
  SeedData._();

  static const String datasetVersion = '2024.1-sample';

  /// Seeds the database if it has not already been seeded. Safe to call
  /// on every app start.
  static Future<void> seedIfNeeded(Database db) async {
    final existing = await db.query(
      'app_metadata',
      where: 'key = ?',
      whereArgs: [AppMetadata.keySeeded],
      limit: 1,
    );
    if (existing.isNotEmpty && existing.first['value'] == 'true') {
      return;
    }

    await db.transaction((txn) async {
      await _seedConstitution(txn);
      await _seedCivilCode(txn);
      await _seedFlagCode(txn);

      final now = DateTime.now().toIso8601String();
      await txn.insert('app_metadata', {
        'key': AppMetadata.keySeeded,
        'value': 'true',
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      await txn.insert('app_metadata', {
        'key': AppMetadata.keyDatasetVersion,
        'value': datasetVersion,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      await txn.insert('app_metadata', {
        'key': AppMetadata.keyLastUpdated,
        'value': now,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  static Future<void> _seedConstitution(Transaction txn) async {
    const lawId = 'const-1987';
    await txn.insert('laws', {
      'id': lawId,
      'title': '1987 Constitution of the Republic of the Philippines',
      'code': 'CONST 1987',
      'jurisdiction': 'Philippines',
      'version_date': '1987-02-02',
      'status': 'in_force',
      'source_url': 'https://www.officialgazette.gov.ph/constitutions/1987-constitution/',
      'created_at': DateTime.now().toIso8601String(),
    });

    const art3NodeId = 'const-art3';
    await txn.insert('hierarchy_nodes', {
      'id': art3NodeId,
      'law_id': lawId,
      'parent_id': null,
      'type': 'Article',
      'number': 'III',
      'title': 'Bill of Rights',
      'order_index': 1,
    });

    await txn.insert('articles', {
      'id': 'const-preamble',
      'law_id': lawId,
      'node_id': null,
      'article_number': 'Preamble',
      'title': 'Preamble',
      'body':
          'We, the sovereign Filipino people, imploring the aid of Almighty '
          'God, in order to build a just and humane society and establish a '
          'Government that shall embody our ideals and aspirations, promote '
          'the common good, conserve and develop our patrimony, and secure '
          'to ourselves and our posterity the blessings of independence and '
          'democracy under the rule of law and a regime of truth, justice, '
          'freedom, love, equality, and peace, do ordain and promulgate this '
          'Constitution.',
      'order_index': 0,
    });

    await txn.insert('articles', {
      'id': 'const-art3-sec1',
      'law_id': lawId,
      'node_id': art3NodeId,
      'article_number': 'Sec. 1',
      'title': 'Due Process and Equal Protection',
      'body':
          'No person shall be deprived of life, liberty, or property without '
          'due process of law, nor shall any person be denied the equal '
          'protection of the laws.',
      'order_index': 1,
    });

    await txn.insert('articles', {
      'id': 'const-art3-sec2',
      'law_id': lawId,
      'node_id': art3NodeId,
      'article_number': 'Sec. 2',
      'title': 'Searches and Seizures',
      'body':
          'The right of the people to be secure in their persons, houses, '
          'papers, and effects against unreasonable searches and seizures of '
          'whatever nature and for any purpose shall be inviolable, and no '
          'search warrant or warrant of arrest shall issue except upon '
          'probable cause to be determined personally by the judge after '
          'examination under oath or affirmation of the complainant and the '
          'witnesses he may produce, and particularly describing the place '
          'to be searched and the persons or things to be seized.',
      'order_index': 2,
    });

    await txn.insert('articles', {
      'id': 'const-art3-sec3',
      'law_id': lawId,
      'node_id': art3NodeId,
      'article_number': 'Sec. 3',
      'title': 'Privacy of Communication',
      'body':
          '(1) The privacy of communication and correspondence shall be '
          'inviolable except upon lawful order of the court, or when public '
          'safety or order requires otherwise, as prescribed by law.\n'
          '(2) Any evidence obtained in violation of this or the preceding '
          'section shall be inadmissible for any purpose in any proceeding.',
      'order_index': 3,
    });

    await txn.insert('articles', {
      'id': 'const-art3-sec4',
      'law_id': lawId,
      'node_id': art3NodeId,
      'article_number': 'Sec. 4',
      'title': 'Freedom of Speech, Expression, and the Press',
      'body':
          'No law shall be passed abridging the freedom of speech, of '
          'expression, or of the press, or the right of the people '
          'peaceably to assemble and petition the government for redress of '
          'grievances.',
      'order_index': 4,
    });

    // Cross references between related Bill of Rights provisions.
    await txn.insert('cross_references', {
      'id': 'xref-const-sec2-sec3',
      'from_article_id': 'const-art3-sec2',
      'to_article_id': 'const-art3-sec3',
      'ref_text': 'See Sec. 3 on inadmissibility of unlawfully obtained evidence',
    });
    await txn.insert('cross_references', {
      'id': 'xref-const-sec3-sec2',
      'from_article_id': 'const-art3-sec3',
      'to_article_id': 'const-art3-sec2',
      'ref_text': 'See Sec. 2 on unreasonable searches and seizures',
    });
  }

  static Future<void> _seedCivilCode(Transaction txn) async {
    const lawId = 'civil-code-ra386';
    await txn.insert('laws', {
      'id': lawId,
      'title': 'Civil Code of the Philippines (Republic Act No. 386)',
      'code': 'R.A. 386',
      'jurisdiction': 'Philippines',
      'version_date': '1950-08-30',
      'status': 'in_force',
      'source_url': 'https://www.officialgazette.gov.ph/1949/06/18/republic-act-no-386/',
      'created_at': DateTime.now().toIso8601String(),
    });

    const bookNodeId = 'cc-book1';
    await txn.insert('hierarchy_nodes', {
      'id': bookNodeId,
      'law_id': lawId,
      'parent_id': null,
      'type': 'Book',
      'number': 'I',
      'title': 'Persons',
      'order_index': 1,
    });

    const titleNodeId = 'cc-book1-title1';
    await txn.insert('hierarchy_nodes', {
      'id': titleNodeId,
      'law_id': lawId,
      'parent_id': bookNodeId,
      'type': 'Title',
      'number': 'I',
      'title': 'Civil Personality',
      'order_index': 1,
    });

    const chapterNodeId = 'cc-book1-title1-ch1';
    await txn.insert('hierarchy_nodes', {
      'id': chapterNodeId,
      'law_id': lawId,
      'parent_id': titleNodeId,
      'type': 'Chapter',
      'number': '1',
      'title': 'Civil Personality',
      'order_index': 1,
    });

    final articles = <Map<String, Object?>>[
      {
        'id': 'cc-art-37',
        'article_number': 'Art. 37',
        'title': 'Juridical Capacity and Capacity to Act',
        'body':
            'Juridical capacity, which is the fitness to be the subject of '
            'legal relations, is inherent in every natural person and is '
            'lost only through death. Capacity to act, which is the power '
            'to do acts with legal effect, is acquired and may be lost.',
      },
      {
        'id': 'cc-art-38',
        'article_number': 'Art. 38',
        'title': 'Restrictions on Capacity to Act',
        'body':
            'Minority, insanity or imbecility, the state of being a '
            'deaf-mute, prodigality and civil interdiction are mere '
            'restrictions on capacity to act, and do not exempt the '
            'incapacitated person from certain obligations, as when the '
            'latter arise from his acts or from property relations, such as '
            'easements.',
      },
      {
        'id': 'cc-art-39',
        'article_number': 'Art. 39',
        'title': 'Circumstances Modifying Capacity to Act',
        'body':
            'The following circumstances, among others, modify or limit '
            'capacity to act: age, insanity, imbecility, the state of being '
            'a deaf-mute, penalty, prodigality, family relations, alienage, '
            'absence, insolvency and trusteeship. The consequences of these '
            'circumstances are governed in this Code, other codes, the '
            'Rules of Court, and in special laws. Capacity to act is not '
            'limited on account of religious belief or political opinion. '
            'A married woman, twenty-one years of age or over, is '
            'qualified for all acts of civil life, except in cases '
            'specified by law.',
      },
      {
        'id': 'cc-art-40',
        'article_number': 'Art. 40',
        'title': 'Birth Determines Personality',
        'body':
            'Birth determines personality; but the conceived child shall be '
            'considered born for all purposes that are favorable to it, '
            'provided it be born later with the conditions specified in '
            'the following article.',
      },
      {
        'id': 'cc-art-41',
        'article_number': 'Art. 41',
        'title': 'When a Fetus is Considered Born',
        'body':
            'For civil purposes, the fetus is considered born if it is '
            'alive at the time it is completely delivered from the '
            'mother\'s womb. However, if the fetus had an intra-uterine '
            'life of less than seven months, it is not deemed born if it '
            'dies within twenty-four hours after its complete delivery '
            'from the maternal womb.',
      },
      {
        'id': 'cc-art-42',
        'article_number': 'Art. 42',
        'title': 'Extinguishment of Civil Personality',
        'body':
            'Civil personality is extinguished by death. The effect of '
            'death upon the rights and obligations of the deceased is '
            'determined by law, by contract and by will.',
      },
      {
        'id': 'cc-art-43',
        'article_number': 'Art. 43',
        'title': 'Presumption of Survivorship',
        'body':
            'If there is a doubt, as between two or more persons who are '
            'called to succeed each other, as to which of them died first, '
            'whoever alleges the death of one prior to the other, shall '
            'prove the same; in the absence of proof, it is presumed that '
            'they died at the same time and there shall be no transmission '
            'of rights from one to the other.',
      },
      {
        'id': 'cc-art-44',
        'article_number': 'Art. 44',
        'title': 'Juridical Persons',
        'body':
            'The following are juridical persons: (1) The State and its '
            'political subdivisions; (2) Other corporations, institutions '
            'and entities for public interest or purpose, created by law; '
            'their personality begins as soon as they have been '
            'constituted according to law; (3) Corporations, partnerships '
            'and associations for private interest or purpose to which the '
            'law grants a juridical personality, separate and distinct from '
            'that of each shareholder, partner or member.',
      },
      {
        'id': 'cc-art-45',
        'article_number': 'Art. 45',
        'title': 'Laws Governing Juridical Persons',
        'body':
            'Juridical persons mentioned in Nos. 1 and 2 of the preceding '
            'article are governed by the laws creating or recognizing '
            'them. Private corporations are regulated by laws of general '
            'application on the subject. Partnerships and associations for '
            'private interest or purpose are governed by the provisions of '
            'this Code concerning partnerships.',
      },
      {
        'id': 'cc-art-46',
        'article_number': 'Art. 46',
        'title': 'Powers of Juridical Persons',
        'body':
            'Juridical persons may acquire and possess property of all '
            'kinds, as well as incur obligations and bring civil or '
            'criminal actions, in conformity with the laws and regulations '
            'of their organization.',
      },
      {
        'id': 'cc-art-47',
        'article_number': 'Art. 47',
        'title': 'Dissolution of Juridical Persons',
        'body':
            'Upon the dissolution of corporations, institutions and other '
            'entities for public interest or purpose mentioned in No. 2 of '
            'Article 44, their property and other assets shall be applied '
            'to similar purposes, or, if not possible, to some other public '
            'purpose in the province, city, or municipality in which they '
            'were located. If the entity was already dissolved, and no '
            'plan of distribution is stated, the disposition shall be '
            'governed by the special laws thereon; and in default of such '
            'laws, by escheat to the Republic of the Philippines.',
      },
    ];

    for (var i = 0; i < articles.length; i++) {
      final a = articles[i];
      await txn.insert('articles', {
        'id': a['id'],
        'law_id': lawId,
        'node_id': chapterNodeId,
        'article_number': a['article_number'],
        'title': a['title'],
        'body': a['body'],
        'order_index': 37 + i,
      });
    }

    final crossRefs = <List<String>>[
      ['cc-art-38', 'cc-art-39', 'See Art. 39 for the circumstances modifying capacity to act'],
      ['cc-art-40', 'cc-art-41', 'See Art. 41 for the conditions under which a fetus is considered born'],
      ['cc-art-41', 'cc-art-40', 'See Art. 40 on birth determining personality'],
      ['cc-art-42', 'cc-art-43', 'See Art. 43 on the presumption of survivorship'],
      ['cc-art-44', 'cc-art-45', 'See Art. 45 on laws governing juridical persons'],
      ['cc-art-44', 'cc-art-47', 'See Art. 47 on dissolution of juridical persons'],
    ];
    for (final r in crossRefs) {
      await txn.insert('cross_references', {
        'id': 'xref-${r[0]}-${r[1]}',
        'from_article_id': r[0],
        'to_article_id': r[1],
        'ref_text': r[2],
      });
    }
  }

  static Future<void> _seedFlagCode(Transaction txn) async {
    const lawId = 'flag-code-ra8491';
    await txn.insert('laws', {
      'id': lawId,
      'title': 'Flag and Heraldic Code of the Philippines (Republic Act No. 8491)',
      'code': 'R.A. 8491',
      'jurisdiction': 'Philippines',
      'version_date': '1998-02-12',
      'status': 'in_force',
      'source_url': 'https://www.officialgazette.gov.ph/1998/02/12/republic-act-no-8491/',
      'created_at': DateTime.now().toIso8601String(),
    });

    const chapterNodeId = 'flag-chapter1';
    await txn.insert('hierarchy_nodes', {
      'id': chapterNodeId,
      'law_id': lawId,
      'parent_id': null,
      'type': 'Chapter',
      'number': 'I',
      'title': 'The National Flag',
      'order_index': 1,
    });

    final sections = <Map<String, Object?>>[
      {
        'id': 'flag-sec1',
        'article_number': 'Sec. 1',
        'title': 'Short Title',
        'body':
            'This Act shall be known as the "Flag and Heraldic Code of the '
            'Philippines".',
      },
      {
        'id': 'flag-sec2',
        'article_number': 'Sec. 2',
        'title': 'Declaration of Policy',
        'body':
            'Reverence and respect shall at all times be accorded the '
            'flag, the anthem, and other national symbols which embody the '
            'national ideals and traditions and which express the '
            'principles of sovereignty and national solidarity. The '
            'heraldic items and devices shall seek to manifest the '
            'national virtues and to inculcate in the minds and hearts of '
            'our people a just pride in their native land, fitting respect '
            'and love for it, and the will and purpose to cherish and '
            'defend it.',
      },
      {
        'id': 'flag-sec3',
        'article_number': 'Sec. 3',
        'title': 'National Flag; Its Design',
        'body':
            'The flag of the Philippines shall have blue, red and white '
            'colors, and consists of a white equilateral triangle basing '
            'on the hoist side, and its width shall be shorter than the '
            'length by one-half, with three, five-pointed golden yellow '
            'stars, one in each angle of the triangle; and a golden yellow '
            'sun with eight primary rays, each of which in turn has three '
            'smaller rays, at the center of the triangle. A blue field '
            'shall be in the upper stripe, while a red field in the lower '
            'stripe. If the blue and red colors are attached vertically, '
            'the blue field shall be at the left and the red field on the '
            'right side.',
      },
      {
        'id': 'flag-sec4',
        'article_number': 'Sec. 4',
        'title': 'Symbolism of Design/Colors',
        'body':
            'The white color shall signify purity and peace; the blue '
            'color, patriotism and idealism; and the red color, patriotism '
            'and valor. The eight-ray sun represents the eight provinces '
            'of Batangas, Bulacan, Cavite, Manila, Laguna, Nueva Ecija, '
            'Pampanga and Tarlac, placed under martial law and declared in '
            'a state of war as of August 30, 1896 by the Philippine '
            'revolutionary generals. The three stars represent the three '
            'main geographic regions of the Philippines where the '
            'revolution took place: Luzon, Visayas, and Mindanao.',
      },
      {
        'id': 'flag-sec5',
        'article_number': 'Sec. 5',
        'title': 'Specifications of Colors, Sizes, Proportion and Devices',
        'body':
            'The color, sizes, proportions, and devices of the national '
            'flag, including the standard sizes to be used for official '
            'occasions, government offices, and ceremonies, shall be as '
            'prescribed in the schedules and specifications set by the '
            'National Historical Institute, in coordination with relevant '
            'government agencies.',
      },
      {
        'id': 'flag-sec6',
        'article_number': 'Sec. 6',
        'title': 'Materials of the National Flag',
        'body':
            'The national flag, when flown, shall be made of good quality '
            'cotton, silk, or other material similarly durable regardless '
            'of the size prescribed for its intended use, so that it may '
            'retain, as much as possible, its true color and appearance, '
            'even with long and continued use.',
      },
      {
        'id': 'flag-sec7',
        'article_number': 'Sec. 7',
        'title': 'Hoisting and Display of the National Flag',
        'body':
            'The flag shall be displayed in all public buildings, official '
            'residences, public plazas, and institutions of learning every '
            'day throughout the year. It shall be hoisted daily at sunrise '
            'and lowered every sunset in schools, government offices, and '
            'other designated places, and must be hoisted briskly and '
            'lowered ceremoniously.',
      },
      {
        'id': 'flag-sec8',
        'article_number': 'Sec. 8',
        'title': 'Places Where the Flag is Displayed',
        'body':
            'The flag shall be permanently hoisted, day and night '
            'throughout the year, in places such as Malacanang Palace, the '
            'Congress of the Philippines, the Supreme Court, and other '
            'sites designated by the National Historical Institute, '
            'provided it is properly illuminated at night.',
      },
      {
        'id': 'flag-sec9',
        'article_number': 'Sec. 9',
        'title': 'Flag Displayed at Half-Mast',
        'body':
            'The flag, when flown at half-mast as a sign of mourning, '
            'shall first be hoisted to the peak for a moment then lowered '
            'to the half-mast position. It shall again be raised to the '
            'peak before it is lowered for the day, in accordance with '
            'periods of national mourning declared by proper authority.',
      },
      {
        'id': 'flag-sec10',
        'article_number': 'Sec. 10',
        'title': 'Manner of Hoisting the Flag',
        'body':
            'The flag shall be hoisted briskly and lowered ceremoniously. '
            'It shall never be allowed to touch the ground, floor, or '
            'water, and shall not be dipped to any person or object as a '
            'salute.',
      },
    ];

    for (var i = 0; i < sections.length; i++) {
      final s = sections[i];
      await txn.insert('articles', {
        'id': s['id'],
        'law_id': lawId,
        'node_id': chapterNodeId,
        'article_number': s['article_number'],
        'title': s['title'],
        'body': s['body'],
        'order_index': i + 1,
      });
    }

    await txn.insert('cross_references', {
      'id': 'xref-flag-sec3-sec4',
      'from_article_id': 'flag-sec3',
      'to_article_id': 'flag-sec4',
      'ref_text': 'See Sec. 4 for the symbolism behind the flag\'s design',
    });
    await txn.insert('cross_references', {
      'id': 'xref-flag-sec4-sec3',
      'from_article_id': 'flag-sec4',
      'to_article_id': 'flag-sec3',
      'ref_text': 'See Sec. 3 for the flag\'s physical design',
    });
    await txn.insert('cross_references', {
      'id': 'xref-flag-sec7-sec10',
      'from_article_id': 'flag-sec7',
      'to_article_id': 'flag-sec10',
      'ref_text': 'See Sec. 10 for the proper manner of hoisting',
    });
  }
}
