import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qless/screens/customer/customer_landing_page.dart';

class AuthScreen extends StatefulWidget {
  final VoidCallback onAuthSuccess;
  final String initialRole;
  final Function(String role)? onRoleSelected;

  const AuthScreen({
    super.key,
    required this.onAuthSuccess,
    this.initialRole = 'user',
    this.onRoleSelected,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _shopNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isLogin = true;
  bool _obscurePassword = true;
  String _selectedRole = 'user';
  String? _errorMessage;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _shopNameController.dispose();
    _ownerNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitAuthForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isLogin) {
        await _signIn();
      } else {
        await _signUp();
      }

      if (mounted) {
        // Notify parent about the selected role
        widget.onRoleSelected?.call(_selectedRole);
        
        widget.onAuthSuccess();
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text(
                _isLogin ? 'Login successful!' : 'Account created successfully!',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _getReadableError(e.code, e.message);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().contains('permission-denied')
              ? 'Database permission denied. Please contact support.'
              : 'An unexpected error occurred. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signIn() async {
    print('🔐 Signing in...');
    
    final credential = await _auth.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    final uid = credential.user?.uid;
    if (uid == null) return;

    print('✅ Sign in successful, UID: $uid');
    
    // Read the existing role from Firestore (don't overwrite it!)
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final existingRole = doc.data()?['role'] as String?;
        print('✅ Existing role in Firestore: $existingRole');
        
        // Notify parent about the actual role from Firestore
        if (existingRole != null) {
          widget.onRoleSelected?.call(existingRole);
        }
      }
    } catch (e) {
      print('⚠️ Could not read role from Firestore: $e');
    }
  }

  Future<void> _signUp() async {
    print('📝 Signing up with role: $_selectedRole');
    
    final now = FieldValue.serverTimestamp();

    final credential = await _auth.createUserWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    final uid = credential.user?.uid;
    if (uid == null) return;

    print('✅ Sign up successful, UID: $uid');
    
    // Notify parent immediately about selected role
    widget.onRoleSelected?.call(_selectedRole);

    final userData = <String, dynamic>{
      'email': _emailController.text.trim(),
      'role': _selectedRole,
      'createdAt': now,
      'updatedAt': now,
    };

    if (_selectedRole == 'vendor') {
      final shopName = _shopNameController.text.trim();
      final ownerName = _ownerNameController.text.trim();
      
      print('📝 Vendor data - Shop: "$shopName", Owner: "$ownerName"');
      
      userData.addAll({
        'shopName': shopName,
        'ownerName': ownerName,
        'status': 'pending',  // Vendor status starts as pending
        'isActive': true,
        'isOpen': false,  // Store starts as closed
        'phone': '',
        'address': '',
        'description': '',
      });
    } else {
      userData.addAll({
        'name': _nameController.text.trim(),
      });
    }

    try {
      print('💾 Saving to Firestore: $userData');
      await _firestore.collection('users').doc(uid).set(userData);
      print('✅ User data saved to Firestore successfully');
      
      // Verify the data was saved
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        print('✅ Verification: Document exists with data: ${doc.data()}');
      } else {
        print('⚠️ Warning: Document was not found after save');
      }
    } catch (e) {
      print('❌ Firestore write failed: $e');
      // Firestore write failed — delete the just-created Auth account so
      // the user can retry without getting "email-already-in-use".
      await credential.user?.delete();
      rethrow;
    }
  }

  Future<String> _getStoredRole(String uid) async {
    try {
      // Try cache first for faster response
      final cachedDoc = await _firestore
          .collection('users')
          .doc(uid)
          .get(const GetOptions(source: Source.cache));
      
      if (cachedDoc.exists) {
        return _extractRoleFromDoc(cachedDoc);
      }
    } catch (_) {
      // Cache miss, continue to server
    }

    // Fetch from server
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) {
      return 'user';
    }

    return _extractRoleFromDoc(doc);
  }

  String _extractRoleFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final role = data?['role'] as String?;
    if (role == 'vendor' || role == 'user') {
      return role!;
    }

    final hasVendorFields =
        (data?['shopName'] as String?)?.isNotEmpty == true ||
            (data?['ownerName'] as String?)?.isNotEmpty == true;
    return hasVendorFields ? 'vendor' : 'user';
  }

  String _getReadableError(String code, [String? message]) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'invalid-credential':
        return 'Invalid email or password. Please check your credentials.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled in Firebase.';
      case 'role-mismatch':
        return message ?? 'Wrong role selected. Please choose the correct role.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return message ?? 'Authentication failed. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFF6B35),
              Color(0xFFFF8C42),
              Color(0xFFFFA559),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo & Brand
                      _buildBrandSection(),
                      const SizedBox(height: 32),

                      // Auth Card
                      Container(
                        width: size.width > 500 ? 420 : double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(28),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Title
                              Text(
                                _isLogin
                                    ? '${_selectedRole == 'vendor' ? 'Vendor' : 'User'} Login'
                                    : '${_selectedRole == 'vendor' ? 'Vendor' : 'User'} Sign Up',
                                style: GoogleFonts.poppins(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2D2D2D),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _isLogin
                                    ? 'Sign in as ${_selectedRole == 'vendor' ? 'vendor' : 'user'}'
                                    : 'Create your ${_selectedRole == 'vendor' ? 'vendor' : 'user'} account',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),

                              SegmentedButton<String>(
                                segments: const [
                                  ButtonSegment<String>(
                                    value: 'user',
                                    label: Text('User'),
                                    icon: Icon(Icons.person_outline),
                                  ),
                                  ButtonSegment<String>(
                                    value: 'vendor',
                                    label: Text('Vendor'),
                                    icon: Icon(Icons.storefront_outlined),
                                  ),
                                ],
                                selected: {_selectedRole},
                                onSelectionChanged: (value) {
                                  setState(() {
                                    _selectedRole = value.first;
                                    _errorMessage = null;
                                  });
                                },
                                showSelectedIcon: false,
                              ),
                              const SizedBox(height: 28),

                              // Error message
                              if (_errorMessage != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red[50],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.red[200]!,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.error_outline,
                                          color: Colors.red[700], size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _errorMessage!,
                                          style: GoogleFonts.inter(
                                            color: Colors.red[700],
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],

                              if (!_isLogin && _selectedRole == 'user') ...[
                                _buildTextField(
                                  controller: _nameController,
                                  label: 'Full Name',
                                  hint: 'Your name',
                                  icon: Icons.person_outline,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter your name';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                              ],

                              if (!_isLogin && _selectedRole == 'vendor') ...[
                                _buildTextField(
                                  controller: _shopNameController,
                                  label: 'Shop Name',
                                  hint: 'Your shop name',
                                  icon: Icons.store_outlined,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter your shop name';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _ownerNameController,
                                  label: 'Owner Name',
                                  hint: 'Owner full name',
                                  icon: Icons.badge_outlined,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter owner name';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                              ],

                              // Email field
                              _buildTextField(
                                controller: _emailController,
                                label: 'Email Address',
                                hint: 'you@example.com',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                      .hasMatch(value.trim())) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Password field
                              _buildTextField(
                                controller: _passwordController,
                                label: 'Password',
                                hint: '••••••••',
                                icon: Icons.lock_outline,
                                obscureText: _obscurePassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: Colors.grey[500],
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  if (value.trim().length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),

                              // Submit button
                              SizedBox(
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _submitAuthForm,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFF6B35),
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor:
                                        const Color(0xFFFF6B35).withOpacity(0.6),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ),
                                        )
                                      : Text(
                                          _isLogin ? 'Sign In' : 'Create Account',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              TextButton(
                                onPressed: _isLoading
                                    ? null
                                    : () {
                                        setState(() {
                                          _isLogin = !_isLogin;
                                          _errorMessage = null;
                                        });
                                      },
                                child: Text(
                                  _isLogin
                                      ? 'Don\'t have an account? Sign Up'
                                      : 'Already have an account? Sign In',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFFFF6B35),
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: _isLoading
                                    ? null
                                    : () {
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const CustomerLandingPage(),
                                          ),
                                        );
                                      },
                                child: Text(
                                  'Continue as Guest',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandSection() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'Q',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF6B35),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'QLess',
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          'Authentication Portal',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white.withOpacity(0.9),
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: GoogleFonts.inter(fontSize: 15),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          color: Colors.grey[600],
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          color: Colors.grey[400],
        ),
        prefixIcon: Icon(icon, color: Colors.grey[500], size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF6B35), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }
}
