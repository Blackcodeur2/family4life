-- Solution 1: Supprimer la contrainte de clé étrangère problématique
-- Cette commande supprime la contrainte qui référence la table "beneficiaries"
ALTER TABLE contributions 
DROP CONSTRAINT IF EXISTS contribution_beneficiary_id_fkey;

-- Solution 2 (Optionnelle): Si vous voulez que beneficiary_id référence la table profiles
-- Décommentez ces lignes si vous voulez conserver une contrainte mais vers profiles
-- ALTER TABLE contributions 
-- ADD CONSTRAINT contributions_beneficiary_id_fkey 
-- FOREIGN KEY (beneficiary_id) 
-- REFERENCES profiles(id) 
-- ON DELETE SET NULL;

-- Vérifier que la colonne beneficiary_id peut accepter NULL
ALTER TABLE contributions 
ALTER COLUMN beneficiary_id DROP NOT NULL;
