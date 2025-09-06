import 'package:fizzi/feature/auth/domain/entities/app_user.dart';
import 'package:fizzi/feature/auth/domain/repositories/auth_repo.dart';
import 'package:fizzi/feature/auth/presentation/cubits/auth_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState>{
  final AuthRepo authRepo;
  AppUser? _currentUser;

  AuthCubit({required this.authRepo}):super(AuthInitial());

  // is user authenticated
  void checkAuth()async{
    final AppUser? user=await authRepo.getCurrentUser();

    if(user!=null){
      _currentUser=user;
      emit(Authenticated(user));
    }else{
      emit(UnAuthenticated());
    }
  }

  // get current user
  AppUser? get currentUser=> _currentUser;

  // login with email and pass
  Future<void> login(String email,String password) async {
    try{
      emit(AuthLoading());

      final user=await authRepo.loginWithEmailPassword(email, password);

      if(user!=null){
        _currentUser=user;
        emit(Authenticated(user));
      }else{
        emit(UnAuthenticated());
      }
    }catch (e){
      emit(AuthError(e.toString()));
      emit(UnAuthenticated());

    }

  }

  //register
  Future<void> register(String name,String email,String password) async{
    try{
      emit(AuthLoading());

      final user=await authRepo.registerWithEmailPassword(name, email, password);

      if(user!=null){
        _currentUser=user;
        emit(Authenticated(user));
      }else{
        emit(UnAuthenticated());
      }
    }catch (e){
      emit(AuthError(e.toString()));
      emit(UnAuthenticated());

    }
  }

  // logout
  Future<void> logout()async {
    // TODO: implement logout

    authRepo.logout();
    emit(UnAuthenticated());
  }
}