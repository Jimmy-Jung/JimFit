//
//  NotificationViewController.swift
//  Bbiyong-Biyong
//
//  Created by Jade Yoo on 2023/04/14.
//

import UIKit
import SnapKit

class NotificationViewController: UIViewController {
    // MARK: - Properties
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "daily_notifications".localized
        label.font = K.Font.Header2
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "daily_notifications_message".localized
        label.font = K.Font.Body1
        label.numberOfLines = 1
        label.textAlignment = .left
        label.textColor = .darkGray
        return label
    }()
    
    let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .compact
        picker.date = Date()
        picker.datePickerMode = .time
        picker.locale = Locale(identifier: "locale_identifier".localized)
        picker.timeZone = .autoupdatingCurrent
        picker.tintColor = .green
        picker.contentHorizontalAlignment = .leading
        picker.minuteInterval = 5
        return picker
    }()
    
    private lazy var dailyNotificationSwitch: UISwitch = {
        let modeSwitch = UISwitch()
        modeSwitch.onTintColor = .systemGreen
        modeSwitch.contentHorizontalAlignment = .trailing
        modeSwitch.isOn = isDailyNotiOn
        return modeSwitch
    }()
    
    private lazy var upperStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [datePicker, dailyNotificationSwitch])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()
    
    private let userNotificationCenter = UNUserNotificationCenter.current()
    
    private var isDailyNotiOn = UM.isDailyNotiOn {
        didSet {
            UM.isDailyNotiOn = isDailyNotiOn
            datePicker.isEnabled = isDailyNotiOn
        }
    }
  
    
    // MARK: - Life cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(#function)
        setDatePicker()
        setNavigationBarAppearance()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.addTarget(self, action: #selector(timeSetHasChanged), for: .valueChanged)
        dailyNotificationSwitch.addTarget(self, action: #selector(updateNotificationSetting), for: .valueChanged)
        
        configure()
    }
    
    // MARK: - Actions
    @objc func timeSetHasChanged(_ sender: UIDatePicker) {
        updateNotificationSetting(dailyNotificationSwitch)
        UM.notiTime = sender.date
    }
    
    @objc func updateNotificationSetting(_ sender: UISwitch) {
        if sender.isOn {
            checkNotificationPermission()
        } else {
                userNotificationCenter.removePendingNotificationRequests(withIdentifiers: ["dailyNoti"])
                isDailyNotiOn = false
                print("Notification: 매일 알림 취소")
        }
    }
    
    func requestNotificationAuthorization() {
        let authOptions = UNAuthorizationOptions(arrayLiteral: .alert, .sound)
        
        userNotificationCenter.requestAuthorization(options: authOptions) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    self.sendDailyNotification(baseTime: self.datePicker.date)
                    self.isDailyNotiOn = true
                }
                print("Notification: 설정 완료")
            } else {
                if let error {
                    print("Notification Error: ", error)
                }
            }
        }
    }
    
    func checkNotificationAuthorization() {
        print("Notification: 권한 확인")
        userNotificationCenter.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                DispatchQueue.main.async {
                    self.sendDailyNotification(baseTime: self.datePicker.date)
                    self.isDailyNotiOn = true
                    self.dailyNotificationSwitch.isOn = true
                }
                print("Notification: 설정 완료")
            } else {
                print("Notification: 설정되지 않음")
            }
        }
    }
    
    func checkNotificationPermission() {
        userNotificationCenter.getNotificationSettings { [weak self] settings in
            guard let self else { return }
            DispatchQueue.main.async {
                if settings.authorizationStatus == .denied {
                    self.showAlert(title: "notification_permission_denied".localized, message: "notification_permission_denied_message".localized, preferredStyle: .alert, doneTitle: "go_to_settings".localized, cancelTitle: "cancel".localized) { _ in
                        self.openAppSettings()
                        self.dailyNotificationSwitch.isOn = false
                    } cancelHandler: { _ in
                        self.dailyNotificationSwitch.isOn = false
                    }
                    
                    
                } else {
                    self.requestNotificationAuthorization()
                }
            }
        }
    }
    
    func openAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
    }

    // MARK: - Helpers
    func configure() {
        view.backgroundColor = .systemBackground
        [titleLabel, descriptionLabel, upperStackView].forEach {
            view.addSubview($0)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(15)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(15)
        }
        
        upperStackView.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(15)
        }
   
    }
    
    func sendDailyNotification(baseTime: Date) {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "time_to_exercise".localized
        notificationContent.body = "record_your_exercise".localized
        notificationContent.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        dateComponents.hour = baseTime.hour
        dateComponents.minute = baseTime.minute

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )
        
        let request = UNNotificationRequest(identifier: "dailyNoti",
                                            content: notificationContent,
                                            trigger: trigger)
        
        userNotificationCenter.add(request) { error in
            if let error {
                print("Notification Error: ", error)
            }
        }
    }
    
    func setDatePicker() {
        datePicker.isEnabled = isDailyNotiOn // 알림 설정 off일 땐, DatePicker 선택 불가

        guard let baseTime = UserDefaults.standard.object(forKey: "notiTime") as? Date else {
            return
        }
        datePicker.date = baseTime
    }
}
