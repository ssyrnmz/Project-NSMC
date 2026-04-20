-- ============================================================
-- NMSC APP — PRESCRIPTION DATABASE SCHEMA
-- Add these tables to your XAMPP/MySQL database (nmsc_app)
-- ============================================================

-- Table 1: prescriptions
-- Stores each prescription issued to a patient.
CREATE TABLE IF NOT EXISTS `prescriptions` (
  `prescription_id`     INT(11)       NOT NULL AUTO_INCREMENT,
  `user_id`             VARCHAR(128)  NOT NULL,          -- Firebase UID of the patient
  `doctor_name`         VARCHAR(255)  NOT NULL,
  `doctor_notes`        TEXT          DEFAULT NULL,
  `prescribed_date`     DATE          NOT NULL,
  `prescription_status` ENUM('current','history') NOT NULL DEFAULT 'current',
  `updated_at`          DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`prescription_id`),
  INDEX `idx_presc_user` (`user_id`),
  INDEX `idx_presc_status` (`prescription_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table 2: prescription_medications
-- Stores the individual medications within each prescription.
CREATE TABLE IF NOT EXISTS `prescription_medications` (
  `medication_id`           INT(11)       NOT NULL AUTO_INCREMENT,
  `prescription_id`         INT(11)       NOT NULL,
  `medication_name`         VARCHAR(255)  NOT NULL,
  `medication_quantity`     VARCHAR(100)  NOT NULL,       -- e.g. "500 mg", "2 tablets"
  `medication_instructions` TEXT          NOT NULL,
  PRIMARY KEY (`medication_id`),
  FOREIGN KEY (`prescription_id`)
    REFERENCES `prescriptions`(`prescription_id`)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ============================================================
-- SAMPLE DATA (for testing)
-- ============================================================
INSERT INTO `prescriptions`
  (`user_id`, `doctor_name`, `doctor_notes`, `prescribed_date`, `prescription_status`)
VALUES
  ('REPLACE_WITH_FIREBASE_UID', 'Dr. Marcus Lee',
   'Complete the full course of antibiotics even if you already feel better. Follow up in one month.',
   '2025-09-15', 'current'),
  ('REPLACE_WITH_FIREBASE_UID', 'Dr. Aisha Rahman',
   NULL,
   '2025-03-30', 'current'),
  ('REPLACE_WITH_FIREBASE_UID', 'Dr. Marcus Lee',
   'Rest well and monitor blood pressure daily.',
   '2024-11-05', 'history');

INSERT INTO `prescription_medications`
  (`prescription_id`, `medication_name`, `medication_quantity`, `medication_instructions`)
VALUES
  (1, 'Amoxicillin',  '500 mg', 'Take one tablet every 8 hours with food.'),
  (1, 'Paracetamol',  '650 mg', 'Take one tablet every 6 hours if needed.'),
  (2, 'Metformin',    '500 mg', 'Take once daily after breakfast.'),
  (3, 'Amlodipine',   '5 mg',   'Take one tablet daily at the same time each day.');


-- ============================================================
-- BACKEND PHP FILES REQUIRED (create in nmsc_app/prescription/)
-- ============================================================
-- get_prescriptions.php      → GET all prescriptions for a user by ?id=
-- get_all_prescriptions.php  → GET all prescriptions (admin)
-- add_prescription.php       → POST add new prescription + medications
-- update_prescription.php    → POST update prescription + medications
-- delete_prescription.php    → POST soft-delete (or hard-delete) by id

-- ============================================================
-- EXAMPLE: get_prescriptions.php structure (PHP pseudocode)
-- ============================================================
--
-- 1. Validate user token (include validate/validate.php)
-- 2. Read ?id= and ?sync= from GET params
-- 3. Query:
--      SELECT p.*, m.medication_id, m.medication_name,
--             m.medication_quantity, m.medication_instructions
--      FROM prescriptions p
--      LEFT JOIN prescription_medications m
--        ON p.prescription_id = m.prescription_id
--      WHERE p.user_id = :id
--        AND (sync IS NULL OR p.updated_at > :sync)
--      ORDER BY p.prescribed_date DESC
-- 4. Group medications under each prescription_id
-- 5. Return JSON array of prescriptions each with a "medications" array
