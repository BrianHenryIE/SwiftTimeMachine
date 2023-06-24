//
// Created by Brian Henry on 6/13/23.
//

import Foundation

public enum TmCurrentPhase: String, Decodable {
    case BackupNotRunning = "BackupNotRunning"
    case PreparingSourceVolumes = "PreparingSourceVolumes"
    case FindingChanges = "FindingChanges"
    case ThinningPreBackup = "ThinningPreBackup"
    case Copying = "Copying"
    case ThinningPostBackup = "ThinningPostBackup"
}