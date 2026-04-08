# Vault Template

The initial repository bootstrap script creates a tree centered on the active car:

```text
trunk/
  FormulaElectric/
    2026/
      00_Admin/
        Program_Management/
        Rules_and_Compliance/
        Budget_and_Purchasing/
        Sponsors_and_Outreach/
        Shared_References/
      01_Vehicle/
        Chassis/
          Primary_Structure/
          Secondary_Structure/
          Driver_Cell/
        Suspension/
          Front_Suspension/
          Rear_Suspension/
        Steering/
          Column_and_UJoints/
          Rack_and_Pinion/
        Brakes/
          Pedal_Box/
          Hydraulics/
          Corners/
        Drivetrain/
          Motor_and_Gearbox/
          Differential_and_Axles/
          Mounts_and_Packaging/
        Cooling/
          Motor_Cooling/
          Accumulator_Cooling/
        Aero/
          Front_Aero/
          Rear_Aero/
          Undertray_and_Diffuser/
      02_Electrical/
        Accumulator/
          Container/
          Segments/
          BMS_and_Safety/
        LV_and_Controls/
          LV_Power/
          Harnessing/
          Telemetry_and_DAQ/
          Dashboard_and_HMI/
        Tractive_System/
          HV_Distribution/
          Motor_Controller/
          Interlocks_and_Shutdown/
      03_Testing_and_Validation/
        Test_Plans/
        Vehicle_Setup/
        Data_Review/
      04_Common_Libraries/
        CAD_Standards/
        Vendor_Models/
        Materials_and_Datasheets/
        Common_Hardware/
      99_Archive/
```

## Standard Design Leaf Template

Every design leaf under `01_Vehicle` and `02_Electrical` gets the same subfolders:

```text
01_CAD/
02_Drawings/
03_Manufacturing/
04_Electrical/
05_Analysis/
06_References/
07_Released/
99_Archive/
```

That keeps the vault consistent even when different subsystem leads own different areas.

## Why This Layout

- The top level starts broad and gets narrower as you drill down.
- Common subfolders are the same at the leaves, so nobody has to guess where drawings or released files belong.
- Mechanical and electrical data can coexist without flattening everything into one giant folder.
- The archive exists both globally and locally so teams can retire obsolete material without deleting history.

