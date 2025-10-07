import 'package:flutter_test/flutter_test.dart';
import 'package:navy_encrypt/pages/result/result_page.dart';

void main() {
  test('runCloudSignInWorkflow marks save status true on sign-in success', () async {
    bool updatedStatus;
    var successCallCount = 0;
    var failureCallCount = 0;

    final result = await runCloudSignInWorkflow(
      signIn: () async => true,
      updateSaveStatus: (value) {
        updatedStatus = value;
      },
      onSuccess: () async {
        successCallCount++;
      },
      onFailure: (_) async {
        failureCallCount++;
      },
    );

    expect(result, isTrue);
    expect(updatedStatus, isTrue);
    expect(successCallCount, 1);
    expect(failureCallCount, 0);
  });

  test('runCloudSignInWorkflow keeps save status false when sign-in fails', () async {
    bool updatedStatus;
    Object capturedError;
    var successCallCount = 0;
    var failureCallCount = 0;

    final result = await runCloudSignInWorkflow(
      signIn: () async => false,
      updateSaveStatus: (value) {
        updatedStatus = value;
      },
      onSuccess: () async {
        successCallCount++;
      },
      onFailure: (error) async {
        capturedError = error;
        failureCallCount++;
      },
    );

    expect(result, isFalse);
    expect(updatedStatus, isFalse);
    expect(successCallCount, 0);
    expect(failureCallCount, 1);
    expect(capturedError, isNull);
  });

  test('runCloudSignInWorkflow keeps save status false when sign-in throws', () async {
    bool updatedStatus;
    Object capturedError;
    var successCallCount = 0;
    var failureCallCount = 0;

    final result = await runCloudSignInWorkflow(
      signIn: () async => throw Exception('sign-in failed'),
      updateSaveStatus: (value) {
        updatedStatus = value;
      },
      onSuccess: () async {
        successCallCount++;
      },
      onFailure: (error) async {
        capturedError = error;
        failureCallCount++;
      },
    );

    expect(result, isFalse);
    expect(updatedStatus, isFalse);
    expect(successCallCount, 0);
    expect(failureCallCount, 1);
    expect(capturedError, isA<Exception>());
  });
}
