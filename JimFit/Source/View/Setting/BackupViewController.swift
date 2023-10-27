//
//  BackupViewController.swift
//  JimFit
//
//  Created by 정준영 on 2023/10/25.
//

import UIKit
import Zip

final class BackupViewController: UIViewController {
    
    private var zipFileList: [String] = []
    private let backupView = BackupView()
    private let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.archive], asCopy: true)
    private let backupManager = BackupManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarAppearance(backgroundColor: .systemGroupedBackground)
        configureUI()
        configureData()
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
    }
    private func configureUI() {
        backupView.tableView.delegate = self
        backupView.tableView.dataSource = self
        view.addSubview(backupView)
        backupView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        backupView.backupButton.addAction { [unowned self] in
            HapticsManager.shared.vibrateForSelection()
            self.backupButtonTapped()
        }
        backupView.restoreButton.addAction { [unowned self] in
            HapticsManager.shared.vibrateForSelection()
            self.restoreButtonTapped()
        }
        
    }
    private func backupButtonTapped() {
        let backupData = backupManager.backup()
        switch backupData {
        case .success(let data):
            zipFileList.insert(data, at: 0)
            backupView.noBackupView.isHidden(!zipFileList.isEmpty)
            backupView.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        case .failure(let error):
            HapticsManager.shared.vibrateForNotification(style: .error)
            showAlert(title: error.errorDescription, message: "try_again_message".localized, preferredStyle: .alert, doneTitle: "done".localized, cancelTitle: nil)
        }
    }
    
    func restoreButtonTapped() {
        present(documentPicker, animated: true)
    }
    
    private func configureData() {
        zipFileList = backupManager.fetchZipList()
        backupView.noBackupView.isHidden(!zipFileList.isEmpty)
        backupView.tableView.reloadData()
    }
    private func showActivityViewController(fileName: String) {
        guard let path = documentDirectoryPath() else {
            HapticsManager.shared.vibrateForNotification(style: .error)
            showAlert(title: "no_document_directory".localized, message: "try_again_message".localized, preferredStyle: .alert, doneTitle: "done".localized, cancelTitle: nil)
            return
        }
        let backUpFileURL = path.appendingPathComponent("\(fileName)")
        let vc = UIActivityViewController(activityItems: [backUpFileURL], applicationActivities: nil)
        present(vc, animated: true)
    }
}

// MARK: - UITableViewDelegate, DataSource
extension BackupViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return zipFileList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var content = cell.defaultContentConfiguration()
        content.text = zipFileList[indexPath.row]
        content.textProperties.font = K.Font.CellHeader
        content.image = UIImage(systemName: "doc.zipper")?.renderingColor(.monochrome).font(K.Font.CellHeader)
        content.imageProperties.tintColor = K.Color.Primary.Orange
        content.imageToTextPadding = 8
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "backup".localized
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showActivityViewController(fileName: zipFileList[indexPath.row])
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        HapticsManager.shared.vibrateForNotification(style: .warning)
        showAlert(title: "warning".localized, message: "checking_backup_message".localized, preferredStyle: .alert, doneTitle: "ok".localized, cancelTitle: "cancel".localized, doneHandler:  { [weak self] _ in
            guard let self else { return }
            do {
                try backupManager.removeBackup(fileName: zipFileList[indexPath.row])
                zipFileList.remove(at: indexPath.row)
                backupView.noBackupView.isHidden(!zipFileList.isEmpty)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            } catch {
                let error = error as! BackupManager.BackupError
                HapticsManager.shared.vibrateForNotification(style: .error)
                showAlert(title: error.errorDescription, message: "try_again_message".localized, preferredStyle: .alert, doneTitle: nil, cancelTitle: "done".localized)
            }
        })
    }
}

extension BackupViewController: UIDocumentPickerDelegate {
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print(#function)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileURL = urls.first else {
            print("선택한 파일에 오류가 있습니다.")
            return
        }
        guard let path = documentDirectoryPath() else {
            print("도큐먼트 위치에 오류가 있습니다.")
            return
        }
        
        // 도큐먼트 폴더 내 저장할 경로 설정
        let sandBoxFileURL = path.appendingPathComponent(selectedFileURL.lastPathComponent)
        HapticsManager.shared.vibrateForNotification(style: .warning)
        showAlert(title: "would_restore".localized, message: "would_restore_message".localized, preferredStyle: .alert, doneTitle: "ok".localized, cancelTitle: "cancel".localized, doneHandler: { [weak self] _ in
        // 기존 Realm에 덮어씌우기
        do {
            try Zip.unzipFile(sandBoxFileURL, destination: path, overwrite: true, password: nil, progress: { progress in
                print("Progress: \(progress)")
            }, fileOutputHandler: { [weak self] unzippedFile in
                print("압축해제 완료: \(unzippedFile)")
                self?.showAlert(title: "restore_success".localized, message: "restore_success_message".localized, preferredStyle: .alert, doneTitle: nil, cancelTitle: "done".localized, cancelHandler: { _ in
                    exit(0)
                })
            })
        } catch {
            print("압축 해제에 실패했습니다.")
        }
        })
        
    }
    
}
