//
//  SEDCalculator.swift
//  StopSun
//
//  Created by J on 2/2/26.
//

import Foundation

/// 자외선 노출량(SED) 계산기
///
/// SED (Standard Erythema Dose)는 피부 홍반을 유발하는 표준 자외선 노출 단위입니다.
///
/// ## Overview
///
/// SED는 MED(Minimal Erythema Dose)와 달리 **절대적인 단위**입니다.
/// - MED: 개인마다 다름 (피부 타입별로 홍반이 생기는 최소량)
/// - SED: 누구에게나 동일 (1 SED = 100 J/m²)
///
/// ## 계산 공식
///
/// ```
/// 1. UV Dose (J/m²) = UV Index × 0.025 (W/m²) × 노출 시간 (초)
/// 2. SED = UV Dose ÷ 100
/// 3. 실제 SED = SED ÷ SPF (선크림 적용 시)
/// ```
///
/// ## 사용 예시
///
/// ```swift
/// // UV Index 8, 30분 노출, SPF 30
/// let sed = SEDCalculator.calculate(uvIndex: 8, durationMinutes: 30, spf: 30)
/// // → 0.12 SED
///
/// // 진행률 계산
/// let progress = SEDCalculator.progress(currentSED: 2.0, skinType: .type3)
/// // → 0.5 (50%)
/// ```
///
/// ## Topics
///
/// ### 계산
/// - ``calculate(uvIndex:durationMinutes:spf:)``
/// - ``calculateDose(uvIndex:durationMinutes:)``
///
/// ### 피부 타입별 기준
/// - ``maxSED(for:)``
/// - ``progress(currentSED:skinType:)``
///
/// ### 상수
/// - ``uvIndexToIrradiance``
/// - ``joulesPerSED``
///
struct SEDCalculator {
    
    // MARK: - Initializer
    
    /// 인스턴스화 방지
    private init() {}
    
    // MARK: - Constants
    
    /// UV Index를 Irradiance(W/m²)로 변환하는 계수
    ///
    /// WHO 정의에 따라 UV Index 1 = 0.025 W/m² (erythemal effective UV)
    ///
    /// ```swift
    /// let irradiance = uvIndex * SEDCalculator.uvIndexToIrradiance
    /// // UV Index 10 → 0.25 W/m²
    /// ```
    static let uvIndexToIrradiance: Double = 0.025
    
    /// 1 SED에 해당하는 에너지량 (J/m²)
    ///
    /// CIE(국제조명위원회) 정의에 따라 1 SED = 100 J/m²
    ///
    /// ```swift
    /// let sed = uvDose / SEDCalculator.joulesPerSED
    /// // 300 J/m² → 3.0 SED
    /// ```
    static let joulesPerSED: Double = 100.0
    
    // MARK: - Calculation Methods
    
    /// UV Dose(J/m²) 계산
    ///
    /// UV Index와 노출 시간으로 총 자외선 노출량을 계산합니다.
    /// SPF를 적용하지 않은 순수 노출량입니다.
    ///
    /// - Parameters:
    ///   - uvIndex: 자외선 지수 (0~11+)
    ///   - durationMinutes: 노출 시간 (분)
    ///
    /// - Returns: UV Dose (J/m²)
    ///
    /// ## 계산 공식
    /// ```
    /// UV Dose = UV Index × 0.025 (W/m²) × 노출 시간 (초)
    /// ```
    ///
    /// ## 예시
    /// ```swift
    /// let dose = SEDCalculator.calculateDose(uvIndex: 8, durationMinutes: 30)
    /// // 8 × 0.025 × 1800 = 360 J/m²
    /// ```
    static func calculateDose(uvIndex: Double, durationMinutes: Double) -> Double {
        let durationSeconds = durationMinutes * 60.0
        let irradiance = uvIndex * uvIndexToIrradiance
        return irradiance * durationSeconds
    }
    
    /// SED 계산
    ///
    /// UV Index, 노출 시간, SPF를 고려하여 실제 SED를 계산합니다.
    ///
    /// - Parameters:
    ///   - uvIndex: 자외선 지수 (0~11+)
    ///   - durationMinutes: 노출 시간 (분)
    ///   - spf: 선크림 SPF 값 (nil이면 선크림 미적용)
    ///
    /// - Returns: 계산된 SED 값
    ///
    /// ## 계산 공식
    /// ```
    /// 1. UV Dose (J/m²) = UV Index × 0.025 × 노출 시간 (초)
    /// 2. SED = UV Dose ÷ 100
    /// 3. 실제 SED = SED ÷ SPF (선크림 적용 시)
    /// ```
    ///
    /// ## 예시
    /// ```swift
    /// // 선크림 없이
    /// let sed1 = SEDCalculator.calculate(uvIndex: 8, durationMinutes: 30)
    /// // → 3.6 SED
    ///
    /// // SPF 30 적용
    /// let sed2 = SEDCalculator.calculate(uvIndex: 8, durationMinutes: 30, spf: 30)
    /// // → 0.12 SED
    /// ```
    static func calculate(
        uvIndex: Double,
        durationMinutes: Double,
        spf: Double? = nil
    ) -> Double {
        let dose = calculateDose(uvIndex: uvIndex, durationMinutes: durationMinutes)
        var sed = dose / joulesPerSED
        
        if let spfValue = spf, spfValue >= 1 {
            sed /= spfValue
        }
        
        return sed
    }
    
    // MARK: - Skin Type Methods
    
    /// 피부 타입별 일일 권장 최대 SED
    ///
    /// Fitzpatrick 피부 타입 분류에 따른 일일 권장 최대 자외선 노출량입니다.
    /// 이 값을 초과하면 피부 손상 위험이 있습니다.
    ///
    /// - Parameter skinType: 피부 타입
    /// - Returns: 일일 권장 최대 SED
    ///
    /// ## 피부 타입별 최대 SED
    ///
    /// | 타입 | 설명 | 최대 SED |
    /// |-----|------|---------|
    /// | I | 매우 하얀 피부, 항상 화상 | 1.5 |
    /// | II | 하얀 피부, 쉽게 화상 | 3.0 |
    /// | III | 약간 어두운 피부 | 4.0 |
    /// | IV | 올리브톤/황갈색 피부 | 5.0 |
    /// | V | 갈색 피부 | 7.0 |
    /// | VI | 매우 어두운 피부 | 12.0 |
    ///
    /// ## 예시
    /// ```swift
    /// let maxSED = SEDCalculator.maxSED(for: .type3)
    /// // → 4.0
    /// ```
    static func maxSED(for skinType: SkinType) -> Double {
        switch skinType {
        case .type1: 1.5
        case .type2: 3.0
        case .type3: 4.0
        case .type4: 5.0
        case .type5: 7.0
        case .type6: 12.0
        }
    }
    
    /// SED 진행률 계산
    ///
    /// 현재 SED가 피부 타입별 최대 SED 대비 몇 %인지 계산합니다.
    /// 1.0(100%)을 초과할 수 있습니다.
    ///
    /// - Parameters:
    ///   - currentSED: 현재까지 누적된 SED
    ///   - skinType: 피부 타입
    ///
    /// - Returns: 진행률 (0.0 ~ 1.0+)
    ///
    /// ## 예시
    /// ```swift
    /// // Type III (최대 4.0 SED)에서 2.0 SED 받음
    /// let progress = SEDCalculator.progress(currentSED: 2.0, skinType: .type3)
    /// // → 0.5 (50%)
    ///
    /// // 초과한 경우
    /// let overProgress = SEDCalculator.progress(currentSED: 5.0, skinType: .type3)
    /// // → 1.25 (125%)
    /// ```
    static func progress(currentSED: Double, skinType: SkinType) -> Double {
        let max = maxSED(for: skinType)
        guard max > 0 else { return 0 }
        return currentSED / max
    }
    
    /// 남은 SED 계산
    ///
    /// 일일 권장량까지 남은 SED를 계산합니다.
    /// 이미 초과한 경우 0을 반환합니다.
    ///
    /// - Parameters:
    ///   - currentSED: 현재까지 누적된 SED
    ///   - skinType: 피부 타입
    ///
    /// - Returns: 남은 SED (최소 0)
    ///
    /// ## 예시
    /// ```swift
    /// let remaining = SEDCalculator.remainingSED(currentSED: 2.0, skinType: .type3)
    /// // → 2.0 (4.0 - 2.0)
    /// ```
    static func remainingSED(currentSED: Double, skinType: SkinType) -> Double {
        let max = maxSED(for: skinType)
        return Swift.max(0, max - currentSED)
    }
    
    /// 권장량 초과까지 남은 시간 계산
    ///
    /// 현재 UV Index에서 권장량 초과까지 남은 시간을 계산합니다.
    ///
    /// - Parameters:
    ///   - currentSED: 현재까지 누적된 SED
    ///   - skinType: 피부 타입
    ///   - uvIndex: 현재 UV Index
    ///   - spf: 선크림 SPF 값 (nil이면 미적용)
    ///
    /// - Returns: 남은 시간 (분), 이미 초과했으면 0
    ///
    /// ## 예시
    /// ```swift
    /// // Type III, 현재 2.0 SED, UV Index 8, SPF 없음
    /// let minutes = SEDCalculator.minutesUntilMax(
    ///     currentSED: 2.0,
    ///     skinType: .type3,
    ///     uvIndex: 8
    /// )
    /// // 남은 2.0 SED를 채우는 데 필요한 시간
    /// ```
    static func minutesUntilMax(
        currentSED: Double,
        skinType: SkinType,
        uvIndex: Double,
        spf: Double? = nil
    ) -> Double {
        let remaining = remainingSED(currentSED: currentSED, skinType: skinType)
        guard remaining > 0, uvIndex > 0 else { return 0 }
        
        // 1분당 SED 계산
        var sedPerMinute = calculate(uvIndex: uvIndex, durationMinutes: 1, spf: nil)
        
        if let spfValue = spf, spfValue >= 1 {
            sedPerMinute /= spfValue
        }
        
        guard sedPerMinute > 0 else { return 0 }
        
        return remaining / sedPerMinute
    }
    
    // MARK: - Sunscreen Overlap
        
        /// TimeInDaylight를 선크림 적용 구간으로 분할
        static func splitExposure(
            start: Date,
            end: Date,
            sunscreenHistory: [SunscreenApplication]
        ) -> [ExposureSegment] {
            
            guard start < end else { return [] }
            
            let overlapping = sunscreenHistory
                .filter { $0.appliedAt < end && $0.nextReapplyTime > start }
                .sorted { $0.appliedAt < $1.appliedAt }
            
            guard !overlapping.isEmpty else {
                return [ExposureSegment(startDate: start, endDate: end, spfLevel: nil)]
            }
            
            var timePoints: Set<Date> = [start, end]
            
            for sunscreen in overlapping {
                if sunscreen.appliedAt > start && sunscreen.appliedAt < end {
                    timePoints.insert(sunscreen.appliedAt)
                }
                if sunscreen.nextReapplyTime > start && sunscreen.nextReapplyTime < end {
                    timePoints.insert(sunscreen.nextReapplyTime)
                }
            }
            
            let sorted = timePoints.sorted()
            var segments: [ExposureSegment] = []
            
            for i in 0..<(sorted.count - 1) {
                let segmentStart = sorted[i]
                let segmentEnd = sorted[i + 1]
                let midPoint = segmentStart.addingTimeInterval(
                    segmentEnd.timeIntervalSince(segmentStart) / 2
                )
                
                let activeSunscreen = overlapping.first { $0.isActive(at: midPoint) }
                
                segments.append(ExposureSegment(
                    startDate: segmentStart,
                    endDate: segmentEnd,
                    spfLevel: activeSunscreen?.spfLevel
                ))
            }
            
            return segments
        }
        
        /// 선크림 기록을 고려한 SED 계산
        static func calculateWithSunscreenHistory(
            start: Date,
            end: Date,
            uvIndex: Double,
            sunscreenHistory: [SunscreenApplication]
        ) -> Double {
            
            splitExposure(start: start, end: end, sunscreenHistory: sunscreenHistory)
                .reduce(0) { total, segment in
                    total + calculate(
                        uvIndex: uvIndex,
                        durationMinutes: segment.durationMinutes,
                        spf: segment.spfLevel?.protectionFactor
                    )
                }
        }
}
