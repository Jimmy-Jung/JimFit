//
//  SettingViewController.swift
//  DollarMoreRefactor
//
//  Created by 정준영 on 2023/06/15.
//

import UIKit
import SnapKit
import MessageUI
import SafariServices

/// 세팅 화면
final class SettingViewController: UIViewController {
    
    // MARK: - Properties
    let device = UIDevice.current.model
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.register(
            SettingTableViewCell.self,
            forCellReuseIdentifier: SettingTableViewCell.identifier
        )
        table.register(
            SwitchTableViewCell.self,
            forCellReuseIdentifier: SwitchTableViewCell.identifier
        )
        return table
    }()
    
    
    private var model: [Section] = []
    
    // MARK: - Life cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureData()
        configureUI()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: - Helpers
    private func configureUI() {
        navigationItem.title = "설정"
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    
    private func configureData() {
        self.model.append(
            Section(title: "시스템", options: [
                .switchCell(
                    model: SettingSwitchOption(
                        title: "다크모드",
                        icon: UIImage(systemName: "moon.fill"),
                        iconBackgroundColor: .darkGray, switchValue: UM.isDarkMode,
                        handler: { sender in
                            guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }

                            let windows = window.windows.first
                            windows?.overrideUserInterfaceStyle = sender.isOn ? .dark : .light
                            UM.isDarkMode = sender.isOn
                            
                        }
                    )
                ),
                .staticCell(
                    model: SettingsOption(
                        title: "알림",
                        icon: UIImage(systemName: "bell.fill"),
                        iconBackgroundColor: .systemRed,
                        handler: {
                            let vc = NotificationViewController()
                            vc.navigationItem.title = "알림"
                            self.navigationController?
                                .pushViewController(vc, animated: true)
                        }
                    )
                ),
            ])
        )
        
        self.model.append(
            Section(title: "정보", options: [
                //                .staticCell(
                //                    model: SettingsOption(
                //                        title: "사용 방법",
                //                        icon: UIImage(systemName: "questionmark.circle.fill"),
                //                        iconBackgroundColor: .systemBlue) { [weak self] in
                //                            self?.performSegue(
                //                                withIdentifier: "toHowToUse",
                //                                sender: nil
                //                            )
                //                        }
                //                ),
                .staticCell(
                    model: SettingsOption(
                        title: "send_feedback".localized,
                        icon: UIImage(systemName: "envelope.fill"),
                        iconBackgroundColor: .systemBlue
                    ) { self.makeAlert() }
                ),
                .staticCell(
                    model: SettingsOption(
                        title: "버전",
                        icon: UIImage(systemName: "wand.and.rays.inverse"),
                        iconBackgroundColor: .lightGray) {}
                )
            ])
        )
    }
    
    private func makeAlert() {
        let bodyString = """
                     문의 사항 및 의견을 작성해주세요.
                     
                     
                     
                     -------------------
                     Device Model : \(Utils.getDeviceModelName())
                     Device OS : \(UIDevice.current.systemVersion)
                     App Version : \(Utils.getAppVersion())
                     -------------------
                     """
        
        if MFMailComposeViewController.canSendMail() {
            let vc = MFMailComposeViewController()
            vc.mailComposeDelegate = self
            vc.setToRecipients(["DollarMoreSP@gmail.com"])
            vc.setSubject("email_subject".localized)
            vc.setMessageBody(bodyString, isHTML: false)
            self.present(vc, animated: true, completion: nil)
        } else {
            let urlString = "https://forms.gle/6Tkb4gxmzut2dx9Q7"
            if let url = URL(string: urlString) {
                let safariViewController = SFSafariViewController(url: url)
                
                self.present(safariViewController, animated: true) {
                    self.showAlert(
                        title: "fail_send_email".localized,
                        message: "fail_send_email_message".localized,
                        preferredStyle: .alert,
                        doneTitle: "ok".localized
                    )
                }
            }
        }
    }
    
}

// MARK: - UITableViewDataSource
extension SettingViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return model.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model[section].options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = model[indexPath.section].options[indexPath.row]
        
        switch data.self {
        case .staticCell(let data):
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingTableViewCell.identifier,for: indexPath) as! SettingTableViewCell
            cell.configure(with: data)
            return cell
            
        case .switchCell(let data):
            let cell = tableView.dequeueReusableCell(withIdentifier: SwitchTableViewCell.identifier,for: indexPath) as! SwitchTableViewCell
            cell.configure(with: data)
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = model[section]
        return section.title
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
}

// MARK: - UITableViewDelegate
extension SettingViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let type = model[indexPath.section].options[indexPath.row]
        switch type.self {
        case .staticCell(let data):
            HapticsManager.shared.vibrateForSelection()
            data.handler()
        case .switchCell:
            break
        }
    }
}

// MARK: - MFMailComposeViewControllerDelegate
extension SettingViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
}





