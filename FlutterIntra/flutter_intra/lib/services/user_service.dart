import 'package:flutter_intra/models/models.dart';
import 'package:flutter_intra/services/database_service.dart';

class UserService {
  final DatabaseService _databaseService = DatabaseService();

  // Liste de noms réalistes pour les utilisateurs
  final List<Map<String, String>> _userProfiles = [
    {
      'name': 'Thomas Dubois',
      'username': 'thomas.dubois',
      'email': 'thomas.dubois@entreprise.com',
      'jobTitle': 'Développeur Senior',
      'bio': 'Passionné de développement mobile et web. Amateur de nouvelles technologies.',
      'profilePicture': 'https://randomuser.me/api/portraits/men/1.jpg',
    },
    {
      'name': 'Sophie Martin',
      'username': 'sophie.martin',
      'email': 'sophie.martin@entreprise.com',
      'jobTitle': 'Designer UX/UI',
      'bio': 'Créative et passionnée par l\'expérience utilisateur. Aime le design minimaliste.',
      'profilePicture': 'https://randomuser.me/api/portraits/women/2.jpg',
    },
    {
      'name': 'Alexandre Petit',
      'username': 'alexandre.petit',
      'email': 'alexandre.petit@entreprise.com',
      'jobTitle': 'Chef de Projet',
      'bio': 'Organisé et méthodique. Aime mener des équipes vers le succès.',
      'profilePicture': 'https://randomuser.me/api/portraits/men/3.jpg',
    },
    {
      'name': 'Émilie Leroy',
      'username': 'emilie.leroy',
      'email': 'emilie.leroy@entreprise.com',
      'jobTitle': 'Responsable Marketing',
      'bio': 'Spécialiste en marketing digital. Passionnée par les stratégies de communication.',
      'profilePicture': 'https://randomuser.me/api/portraits/women/4.jpg',
    },
    {
      'name': 'Nicolas Moreau',
      'username': 'nicolas.moreau',
      'email': 'nicolas.moreau@entreprise.com',
      'jobTitle': 'Développeur Backend',
      'bio': 'Expert en bases de données et architecture logicielle.',
      'profilePicture': 'https://randomuser.me/api/portraits/men/5.jpg',
    },
    {
      'name': 'Julie Fournier',
      'username': 'julie.fournier',
      'email': 'julie.fournier@entreprise.com',
      'jobTitle': 'Responsable RH',
      'bio': 'Spécialiste en ressources humaines. Aime créer un environnement de travail positif.',
      'profilePicture': 'https://randomuser.me/api/portraits/women/6.jpg',
    },
    {
      'name': 'Mathieu Girard',
      'username': 'mathieu.girard',
      'email': 'mathieu.girard@entreprise.com',
      'jobTitle': 'Administrateur Système',
      'bio': 'Expert en infrastructure IT et sécurité informatique.',
      'profilePicture': 'https://randomuser.me/api/portraits/men/7.jpg',
    },
    {
      'name': 'Camille Roux',
      'username': 'camille.roux',
      'email': 'camille.roux@entreprise.com',
      'jobTitle': 'Développeuse Frontend',
      'bio': 'Passionnée par les interfaces utilisateur et l\'accessibilité web.',
      'profilePicture': 'https://randomuser.me/api/portraits/women/8.jpg',
    },
    {
      'name': 'Lucas Bernard',
      'username': 'lucas.bernard',
      'email': 'lucas.bernard@entreprise.com',
      'jobTitle': 'Directeur Commercial',
      'bio': 'Expert en négociation et développement commercial.',
      'profilePicture': 'https://randomuser.me/api/portraits/men/9.jpg',
    },
    {
      'name': 'Léa Dupont',
      'username': 'lea.dupont',
      'email': 'lea.dupont@entreprise.com',
      'jobTitle': 'Analyste Financière',
      'bio': 'Spécialiste en analyse financière et gestion de budget.',
      'profilePicture': 'https://randomuser.me/api/portraits/women/10.jpg',
    },
  ];

  // Récupérer un utilisateur par son ID
  Future<User?> getUser(int userId) async {
    final db = await _databaseService.database;
    
    try {
      // Vérifier d'abord dans la base de données
      final results = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
      );
      
      if (results.isNotEmpty) {
        return User.fromMap(results.first);
      }
      
      // Si l'utilisateur n'est pas trouvé dans la base de données,
      // utiliser un profil fictif de notre liste
      final profileIndex = (userId - 1) % _userProfiles.length;
      final profile = _userProfiles[profileIndex];
      
      // Créer un utilisateur avec le profil fictif
      return User(
        id: userId,
        username: profile['username']!,
        email: profile['email']!,
        password: '',
        name: profile['name'],
        profilePicture: profile['profilePicture'],
        jobTitle: profile['jobTitle'],
        bio: profile['bio'],
        role: userId == 1 ? 'admin' : 'employee',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      );
    } catch (e) {
      print('Erreur lors de la récupération de l\'utilisateur: $e');
      return null;
    }
  }

  // Récupérer tous les utilisateurs
  Future<List<User>> getAllUsers() async {
    final db = await _databaseService.database;
    
    try {
      final results = await db.query('users');
      
      if (results.isNotEmpty) {
        return results.map((map) => User.fromMap(map)).toList();
      }
      
      // Si aucun utilisateur n'est trouvé, retourner une liste vide
      return [];
    } catch (e) {
      print('Erreur lors de la récupération des utilisateurs: $e');
      return [];
    }
  }

  // Mettre à jour un utilisateur
  Future<User?> updateUser(User user) async {
    final db = await _databaseService.database;
    
    try {
      await db.update(
        'users',
        user.toMap(),
        where: 'id = ?',
        whereArgs: [user.id],
      );
      
      return user;
    } catch (e) {
      print('Erreur lors de la mise à jour de l\'utilisateur: $e');
      return null;
    }
  }
}
