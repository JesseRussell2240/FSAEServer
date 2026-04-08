#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
    echo "Run this script with sudo or as root."
    exit 1
fi

REPO_NAME="${1:-cfe-solidworks}"
SVN_ROOT="${2:-/srv/svn}"
REPO_PATH="${SVN_ROOT}/${REPO_NAME}"

if [[ -e "${REPO_PATH}" ]]; then
    echo "Repository already exists: ${REPO_PATH}"
    exit 1
fi

svnadmin create "${REPO_PATH}"

BASE_URL="file://${REPO_PATH}"
LEAF_TEMPLATE=(
    "01_CAD"
    "02_Drawings"
    "03_Manufacturing"
    "04_Electrical"
    "05_Analysis"
    "06_References"
    "07_Released"
    "99_Archive"
)

BASE_PATHS=(
    "/trunk"
    "/branches"
    "/tags"
    "/trunk/FormulaElectric"
    "/trunk/FormulaElectric/2026"
    "/trunk/FormulaElectric/2026/00_Admin"
    "/trunk/FormulaElectric/2026/00_Admin/Program_Management"
    "/trunk/FormulaElectric/2026/00_Admin/Rules_and_Compliance"
    "/trunk/FormulaElectric/2026/00_Admin/Budget_and_Purchasing"
    "/trunk/FormulaElectric/2026/00_Admin/Sponsors_and_Outreach"
    "/trunk/FormulaElectric/2026/00_Admin/Shared_References"
    "/trunk/FormulaElectric/2026/01_Vehicle"
    "/trunk/FormulaElectric/2026/01_Vehicle/Chassis"
    "/trunk/FormulaElectric/2026/01_Vehicle/Suspension"
    "/trunk/FormulaElectric/2026/01_Vehicle/Steering"
    "/trunk/FormulaElectric/2026/01_Vehicle/Brakes"
    "/trunk/FormulaElectric/2026/01_Vehicle/Drivetrain"
    "/trunk/FormulaElectric/2026/01_Vehicle/Cooling"
    "/trunk/FormulaElectric/2026/01_Vehicle/Aero"
    "/trunk/FormulaElectric/2026/02_Electrical"
    "/trunk/FormulaElectric/2026/02_Electrical/Accumulator"
    "/trunk/FormulaElectric/2026/02_Electrical/LV_and_Controls"
    "/trunk/FormulaElectric/2026/02_Electrical/Tractive_System"
    "/trunk/FormulaElectric/2026/03_Testing_and_Validation"
    "/trunk/FormulaElectric/2026/03_Testing_and_Validation/Test_Plans"
    "/trunk/FormulaElectric/2026/03_Testing_and_Validation/Vehicle_Setup"
    "/trunk/FormulaElectric/2026/03_Testing_and_Validation/Data_Review"
    "/trunk/FormulaElectric/2026/04_Common_Libraries"
    "/trunk/FormulaElectric/2026/04_Common_Libraries/CAD_Standards"
    "/trunk/FormulaElectric/2026/04_Common_Libraries/Vendor_Models"
    "/trunk/FormulaElectric/2026/04_Common_Libraries/Materials_and_Datasheets"
    "/trunk/FormulaElectric/2026/04_Common_Libraries/Common_Hardware"
    "/trunk/FormulaElectric/2026/99_Archive"
)

DESIGN_LEAVES=(
    "/trunk/FormulaElectric/2026/01_Vehicle/Chassis/Primary_Structure"
    "/trunk/FormulaElectric/2026/01_Vehicle/Chassis/Secondary_Structure"
    "/trunk/FormulaElectric/2026/01_Vehicle/Chassis/Driver_Cell"
    "/trunk/FormulaElectric/2026/01_Vehicle/Suspension/Front_Suspension"
    "/trunk/FormulaElectric/2026/01_Vehicle/Suspension/Rear_Suspension"
    "/trunk/FormulaElectric/2026/01_Vehicle/Steering/Column_and_UJoints"
    "/trunk/FormulaElectric/2026/01_Vehicle/Steering/Rack_and_Pinion"
    "/trunk/FormulaElectric/2026/01_Vehicle/Brakes/Pedal_Box"
    "/trunk/FormulaElectric/2026/01_Vehicle/Brakes/Hydraulics"
    "/trunk/FormulaElectric/2026/01_Vehicle/Brakes/Corners"
    "/trunk/FormulaElectric/2026/01_Vehicle/Drivetrain/Motor_and_Gearbox"
    "/trunk/FormulaElectric/2026/01_Vehicle/Drivetrain/Differential_and_Axles"
    "/trunk/FormulaElectric/2026/01_Vehicle/Drivetrain/Mounts_and_Packaging"
    "/trunk/FormulaElectric/2026/01_Vehicle/Cooling/Motor_Cooling"
    "/trunk/FormulaElectric/2026/01_Vehicle/Cooling/Accumulator_Cooling"
    "/trunk/FormulaElectric/2026/01_Vehicle/Aero/Front_Aero"
    "/trunk/FormulaElectric/2026/01_Vehicle/Aero/Rear_Aero"
    "/trunk/FormulaElectric/2026/01_Vehicle/Aero/Undertray_and_Diffuser"
    "/trunk/FormulaElectric/2026/02_Electrical/Accumulator/Container"
    "/trunk/FormulaElectric/2026/02_Electrical/Accumulator/Segments"
    "/trunk/FormulaElectric/2026/02_Electrical/Accumulator/BMS_and_Safety"
    "/trunk/FormulaElectric/2026/02_Electrical/LV_and_Controls/LV_Power"
    "/trunk/FormulaElectric/2026/02_Electrical/LV_and_Controls/Harnessing"
    "/trunk/FormulaElectric/2026/02_Electrical/LV_and_Controls/Telemetry_and_DAQ"
    "/trunk/FormulaElectric/2026/02_Electrical/LV_and_Controls/Dashboard_and_HMI"
    "/trunk/FormulaElectric/2026/02_Electrical/Tractive_System/HV_Distribution"
    "/trunk/FormulaElectric/2026/02_Electrical/Tractive_System/Motor_Controller"
    "/trunk/FormulaElectric/2026/02_Electrical/Tractive_System/Interlocks_and_Shutdown"
)

URLS=()
for path in "${BASE_PATHS[@]}"; do
    URLS+=("${BASE_URL}${path}")
done

for leaf in "${DESIGN_LEAVES[@]}"; do
    URLS+=("${BASE_URL}${leaf}")
    for subdir in "${LEAF_TEMPLATE[@]}"; do
        URLS+=("${BASE_URL}${leaf}/${subdir}")
    done
done

svn mkdir -m "Initialize CFE SolidWorks vault structure." "${URLS[@]}"

chmod -R 770 "${REPO_PATH}"
chown -R www-data:www-data "${REPO_PATH}"

echo "Created repository: ${REPO_PATH}"
echo "Repo URL: https://conestogaformulaelectric.ca/svn/${REPO_NAME}"
echo "Next step: check out trunk/FormulaElectric/2026 from a Windows workstation."
