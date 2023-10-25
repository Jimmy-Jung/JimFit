//
//  BackupManager.swift
//  JimFit
//
//  Created by 정준영 on 2023/10/25.
//

import Foundation
import Zip

struct BackupManager {
    
    enum BackupError: Error, LocalizedError {
        case noDocumentDirectory
        case noBackupFile
        case zipError
        case failRemove
        
        var errorDescription: String {
            switch self {
            case .noDocumentDirectory:
                return "no_document_directory".localized
            case .noBackupFile:
                return "no_backup_file".localized
            case .zipError:
                return "zip_error".localized
            case .failRemove:
                return "remove_error".localized
                
            }
        }
    }
    
    private func documentDirectoryPath() -> URL? {
        let documentDirectory = FileManager
            .default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first
        return documentDirectory
    }
    
    func backup() -> Result<String, BackupError> {
        // 1. 백업 하고자 하는 파일들의 경로 배열 생성
        var urlPaths = [URL]()
        
        // 2. 도큐먼트 위치
        guard let path = documentDirectoryPath() else {
            return .failure(.noDocumentDirectory)
        }
        
        // 3. 백업하고자 하는 파일 경로
        let realmFile = path.appendingPathComponent("OldExercise.realm")
        
        // 4. 3번 경로가 유효한 지 확인
        guard FileManager.default.fileExists(atPath: realmFile.path) else {
            return .failure(.noBackupFile)
        }
        
        // 5. 압축하고자 하는 파일을 배열에 추가
        urlPaths.append(realmFile)
        
        // 6. 압축
        do {
            let zipFilePath = try Zip.quickZipFiles(urlPaths, fileName: "Backup_\(Date().convert(to: .backup))")
            return .success(zipFilePath.lastPathComponent)
        } catch {
            return .failure(.zipError)
        }
    }
    
    func removeBackup(fileName: String) throws {
        do {
            guard let path = documentDirectoryPath() else { return }
            let docs = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil)
            if let zipFile = docs.filter({ $0.lastPathComponent == fileName}).first {
                do {
                    try FileManager.default.removeItem(at: zipFile)
                } catch {
                    throw BackupError.failRemove
                }
            } else {
                throw BackupError.noBackupFile
            }
        } catch {
            throw BackupError.noBackupFile
        }
    }
    
    func fetchZipList() -> [String] {
        var list: [String] = []
        do {
            guard let path = documentDirectoryPath() else { return list }
            let docs = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil)
            let zip = docs.filter { $0.pathExtension == "zip"}
            for i in zip {
                list.append(i.lastPathComponent)
            }
        } catch {
            print(error)
        }
        return list.sorted(by: >)
    }
}
