//
//  Exercise.swift
//  GymVisual crawler
//
//  Created by 정준영 on 2023/09/22.
//

import Foundation
import RealmSwift

final class Exercise: Object {
    @Persisted var reference: String
    @Persisted var exerciseName: String
    @Persisted var bodyPart: List<String>
    @Persisted var equipmentType: String
    @Persisted var exerciseType: String
    @Persisted var targetMuscles: List<String>
    @Persisted var synergistMuscles: List<String>
    
    convenience init(bodyPart: List<String>, equipmentType: String, exerciseType: String, targetMuscles: List<String>, synergistMuscles: List<String>, reference: String, exerciseName: String) {
        self.init()
        self.bodyPart = bodyPart
        self.equipmentType = equipmentType
        self.exerciseType = exerciseType
        self.targetMuscles = targetMuscles
        self.synergistMuscles = synergistMuscles
        self.reference = reference
        self.exerciseName = exerciseName
    }
}

final class LikedExercise: Object {
    @Persisted var reference: String
    @Persisted var exerciseName: String
    @Persisted var bodyPart: List<String>
    @Persisted var equipmentType: String
    @Persisted var exerciseType: String
    @Persisted var targetMuscles: List<String>
    @Persisted var synergistMuscles: List<String>
    
    convenience init(bodyPart: List<String>, equipmentType: String, exerciseType: String, targetMuscles: List<String>, synergistMuscles: List<String>, reference: String, exerciseName: String) {
        self.init()
        self.bodyPart = bodyPart
        self.equipmentType = equipmentType
        self.exerciseType = exerciseType
        self.targetMuscles = targetMuscles
        self.synergistMuscles = synergistMuscles
        self.reference = reference
        self.exerciseName = exerciseName
    }
}

enum BodyPart: String, CaseIterable {
    case back = "Back"
    case calves = "Calves"
    case cardio = "Cardio"
    case chest = "Chest"
    case feet = "Feet"
    case forearms = "Forearms"
    case fullBody = "Full body"
    case hips = "Hips"
    case neck = "Neck"
    case plyometrics = "Plyometrics"
    case shoulders = "Shoulders"
    case stretching = "Stretching"
    case thighs = "Thighs"
    case upperArms = "Upper Arms"
    case waist = "Waist"
    case weightlifting = "Weightlifting"
    case yoga = "Yoga"
    case none
}

enum EquipmentType: String, CaseIterable {
    case assisted = "Assisted"
    case band = "Band"
    case barbell = "Barbell"
    case battlingRope = "Battling Rope"
    case bodyWeight = "Body weight"
    case bosuBall = "Bosu ball"
    case cable = "Cable"
    case dumbbell = "Dumbbell"
    case ezBarbell = "Ez Barbell"
    case hammer = "Hammer"
    case kettlebell = "Kettlebell"
    case leverageMachine = "Leverage machine"
    case medicineBall = "Medicine Ball"
    case olympicBarbell = "Olympic marbell"
    case powerSled = "Power Sled"
    case resistanceBand = "Resistance Band"
    case roll = "Roll"
    case rollball = "Rollball"
    case rope = "Rope"
    case sledMachine = "Sled machine"
    case smithMachine = "Smith machine"
    case stabilityBall = "Stability ball"
    case stick = "Stick"
    case suspension = "Suspension"
    case trapBar = "Trap Bar"
    case vibratePlate = "Vibrate Plate"
    case weighted = "Weighted"
    case wheelRoller = "Wheel roller"
    case none
}

enum ExerciseType: String {
    case aerobic = "Aerobic"
    case stretching = "Stretching"
    case strength = "Strength"
    case none
}

enum TargetMuscles: String {
    case obliques = "Obliques"
    case brachialis = "Brachialis"
    case deepHipExternalRotators = "Deep Hip External Rotators"
    case adductorMagnus = "Adductor Magnus"
    case trapeziusUpperFibers = "Trapezius Upper Fibers"
    case wristFlexors = "Wrist Flexors"
    case sternocleidomastoid = "Sternocleidomastoid"
    case transverseAbdominus = "Transverse Abdominus"
    case deltoidLateral = "Deltoid Lateral"
    case bicepsBrachii = "Biceps Brachii"
    case deltoidPosterior = "Deltoid Posterior"
    case pectoralisMajorSternalHead = "Pectoralis Major Sternal Head"
    case brachioradialis = "Brachioradialis"
    case iliopsoas = "Iliopsoas"
    case adductorBrevis = "Adductor Brevis"
    case trapeziusLowerFibers = "Trapezius Lower Fibers"
    case serratusAnterior = "Serratus Anterior"
    case gluteusMinimus = "Gluteus Minimus"
    case latissimusDorsi = "Latissimus Dorsi"
    case rectusAbdominis = "Rectus Abdominis"
    case quadriceps = "Quadriceps"
    case deltoidAnterior = "Deltoid Anterior"
    case teresMinor = "Teres Minor"
    case rhomboids = "Rhomboids"
    case hamstrings = "Hamstrings"
    case tibialisAnterior = "Tibialis Anterior"
    case subscapularis = "Subscapularis"
    case adductorLongus = "Adductor Longus"
    case tricepsBrachii = "Triceps Brachii"
    case gracilis = "Gracilis"
    case soleus = "Soleus"
    case wristExtensors = "Wrist Extensors"
    case sartorius = "Sartorius"
    case infraspinatus = "Infraspinatus"
    case gluteusMaximus = "Gluteus Maximus"
    case tensorFasciaeLatae = "Tensor Fasciae Latae"
    case pectineous = "Pectineous"
    case splenius = "Splenius"
    case pectoralisMajorClavicularHead = "Pectoralis Major Clavicular Head"
    case levatorScapulae = "Levator Scapulae"
    case erectorSpinae = "Erector Spinae"
    case gastrocnemius = "Gastrocnemius"
    case trapeziusMiddleFibers = "Trapezius Middle Fibers"
    case teresMajor = "Teres Major"
    case gluteusMedius = "Gluteus Medius"
}

enum SynergistMuscles: String {
    case wristExtensors = "Wrist Extensors"
    case sternocleidomastoid = "Sternocleidomastoid"
    case wristFlexors = "Wrist Flexors"
    case pectoralisMajorClavicularHead = "Pectoralis Major Clavicular Head"
    case serratusAnterior = "Serratus Anterior"
    case trapeziusLowerFibers = "Trapezius Lower Fibers"
    case gracilis = "Gracilis"
    case trapeziusUpperFibers = "Trapezius Upper Fibers"
    case pectineous = "Pectineous"
    case popliteus = "Popliteus"
    case soleus = "Soleus"
    case quadriceps = "Quadriceps"
    case gluteusMaximus = "Gluteus Maximus"
    case iliopsoas = "Iliopsoas"
    case infraspinatus = "Infraspinatus"
    case sartorius = "Sartorius"
    case deltoidAnterior = "Deltoid Anterior"
    case bicepsBrachii = "Biceps Brachii"
    case gastrocnemius = "Gastrocnemius"
    case adductorBrevis = "Adductor Brevis"
    case deltoidLateral = "Deltoid Lateral"
    case levatorScapulae = "Levator Scapulae"
    case tensorFasciaeLatae = "Tensor Fasciae Latae"
    case gluteusMedius = "Gluteus Medius"
    case teresMajor = "Teres Major"
    case subscapularis = "Subscapularis"
    case splenius = "Splenius"
    case brachialis = "Brachialis"
    case pectoralisMajorSternalHead = "Pectoralis Major Sternal Head"
    case tricepsBrachii = "Triceps Brachii"
    case brachioradialis = "Brachioradialis"
    case teresMinor = "Teres Minor"
    case tibialisAnterior = "Tibialis Anterior"
    case adductorMagnus = "Adductor Magnus"
    case hamstrings = "Hamstrings"
    case adductorLongus = "Adductor Longus"
    case obliques = "Obliques"
    case deltoidPosterior = "Deltoid Posterior"
    case latissimusDorsi = "Latissimus Dorsi"
    case erectorSpinae = "Erector Spinae"
    case rectusAbdominis = "Rectus Abdominis"
    case trapeziusMiddleFibers = "Trapezius Middle Fibers"
}
