import '../../../models/job_application_model.dart';
import '../../../models/vacancy_model.dart';
import '../../../models/worker_profile_model.dart';

abstract class JobsRepository {
  // ---- Vacancies ----
  Stream<List<VacancyModel>> watchVacancies({String? city});
  Stream<List<VacancyModel>> watchMyVacancies(String employerId);
  Future<VacancyModel> getVacancy(String vacancyId);
  Future<String> createVacancy(VacancyModel vacancy);
  Future<void> updateVacancy(VacancyModel vacancy);
  Future<void> setVacancyClosed({required String vacancyId, required bool isClosed});
  Future<void> deleteVacancy(String vacancyId);

  // ---- Worker Profiles ----
  Stream<List<WorkerProfileModel>> watchWorkers({String? city, String? profession});
  Future<WorkerProfileModel?> getMyWorkerProfile(String uid);
  Stream<WorkerProfileModel?> watchWorkerProfile(String uid);
  Future<void> saveWorkerProfile(WorkerProfileModel profile);

  // ---- Applications ----
  Future<void> applyToVacancy(JobApplicationModel application);
  Future<bool> hasApplied({required String vacancyId, required String workerId});
  Stream<List<JobApplicationModel>> watchApplicationsForVacancy(String vacancyId);
  Future<void> updateApplicationStatus({
    required String applicationId,
    required ApplicationStatus status,
  });
}
