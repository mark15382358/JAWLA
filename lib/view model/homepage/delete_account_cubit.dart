import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:jawla/core/classes/status.dart';
import 'package:jawla/core/constants/variable.dart';
import 'package:jawla/core/services/services.dart';
import 'package:jawla/data/profile/delete_profile_data_request.dart';
import 'package:jawla/view%20model/app_state.dart';
import 'package:jawla/view/widgets/success_widget.dart';
import 'package:jawla/view/widgets/warning_widget.dart';
import '../../core/constants/routes_name.dart';

class DeleteAccountCubit extends Cubit<AppState> {
  DeleteAccountCubit() : super(Initial());
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController passwordCont = TextEditingController();
  final services = Get.put(Services());

  deleteProfileFun() async {
    emit(Loading());
    Either<Status, Map> response =
        await deleteProfileDataReq(passwordCont.text, Variable().token);
    response.fold((l) {
      if (l.type == StatusType.internetFailure) {
        services.sharedPref!.clear();
        Get.toNamed(AppRoutes().signIn);
        emit(InternetError());
      } else if (l.type == StatusType.serverFailure) {
        services.sharedPref!.clear();
        Get.toNamed(AppRoutes().signIn);
        emit(ServerError());
      } else if (l.type == StatusType.apiFailure) {
        emit(ApiFailure(l.errorData['errors']));
        warningWidget("Failed", Icons.warning, l.errorData['errors']);
      }
    }, (r) {
      emit(Success([]));
      successWidget("Success", "${r['message']}");
      services.sharedPref!.clear();
      Get.offAllNamed(AppRoutes().signIn);
    });
  }
}
