#
#  Copyright 2018-2024 HP Development Company, L.P.
#  All Rights Reserved.
#
# NOTICE:  All information contained herein is, and remains the property of HP Development Company, L.P.
#
# The intellectual and technical concepts contained herein are proprietary to HP Development Company, L.P
# and may be covered by U.S. and Foreign Patents, patents in process, and are protected by
# trade secret or copyright law. Dissemination of this information or reproduction of this material
# is strictly forbidden unless prior written permission is obtained from HP Development Company, L.P.


Set-StrictMode -Version 3.0
$ErrorActionPreference = "Stop"
#requires -Modules "HP.Private","HP.Utility"

if ($PSEdition -eq "Core") {
  Add-Type -Path "$PSScriptRoot\MSAL_4.36.2\netcoreapp2.1\Microsoft.Identity.Client.dll" -IgnoreWarnings -WarningAction SilentlyContinue
}
else {
  Add-Type -Path "$PSScriptRoot\MSAL_4.36.2\net45\Microsoft.Identity.Client.dll" -IgnoreWarnings -WarningAction SilentlyContinue
}

$msgs = @{
  0x031e = @("Sure Start found the primary BIOS in shared flash memory is either corrupted or missing. Possible causes include but not limited to interrupted BIOS update or recent BIOS attack.",1);
  0x031f = @("Sure Start found the backup BIOS is either corrupted or missing. Possible causes include but not limited to interrupted BIOS update.",1);
  0x0320 = @("Sure Start found shared flash memory layout is different from original factory settings.",1);
  0x0322 = @("Sure Start has recovered the primary BIOS in shared flash memory.",0);
  0x0323 = @("Sure Start has updated the backup copy of BIOS.",0);
  0x0324 = @("Sure Start found shared flash memory layout is different from original factory settings and has repaired the shared flash layout.",0);
  0x0326 = @("Sure Start found that the primary BIOS in shared flash memory on resume from Sleep is different than what system originally booted with.",0);
  0x0328 = @("Sure Start found that the 'BIOS Update Policy' setting was set to Locked but was unable to honor policy as backup copy of BIOS may be corrupted or missing.",1);
  0x032a = @("Sure Start received a command to perform a manual recovery.",0);
  0x032b = @("Sure Start integrity checking on backup copy of critical factory configured parameters failed and is no longer being used.",2);
  0x032c = @("Sure Start integrity checking on backup copy of critical network parameters data failed and is no longer being used.",2);
  0x032d = @("Sure Start integrity checking on backup copy of shared flash memory layout description failed and is no longer being used.",2);
  0x032e = @("Sure Start has found and repaired an integrity issue with saved audit logs; some logging data may have been lost.",1);
  0x032f = @("Sure Start policy settings have been corrupted and reverted to factory defaults.",1);
  0x0330 = @("System was placed in manufacturing programming mode.",1);
  0x0331 = @("System was taken out of manufacturing programming mode.",0);
  0x0332 = @("Sure Start found that backup and primary copy of BIOS do not match.",0);
  0x0333 = @("Sure Start received a request to perform a self test.",0);
  0x0334 = @("The permanent fuse in the HP Sure Start embedded controller has been modified to block the automated process that typically locks this platform to production firmware only. This should only occur on platforms that are used by HP for development purposes or exception manufacturing processes. Permanently locking this device to use production firmware only will now require a manual process.",1);
  0x0335 = @("The permanent fuse in the HP Sure Start embedded controller has been modified such that HP Sure Start will only accept HP production firmware.",0);
  0x0336 = @("A BIOS update was blocked because it did not meet the policy version requirements.",1);
  0x0337 = @("A BIOS update was blocked because it would have rolled back the current BIOS to an older BIOS which was prohibited by policy.",1);
  0x0338 = @("Runtime Verification (S0 Sure Start) has been skipped as EpSC was not able to read a correct known data back (FDT Signature).",1);

  0x801f = @("Sure Start repaired the onboard ethernet configuration data.",1);
  0x8020 = @("Sure Start has recovered the primary BIOS in shared flash memory from a copy located on flash.",1);
  0x8021 = @("Sure Start has recovered the primary BIOS in shared flash memory from a copy located on the HDD.",1);
  0x8022 = @("Sure Start has recovered the primary BIOS in shared flash memory from a copy located on a USB Key.",1);
  0x8026 = @("Sure Start has repaired machine specific data that was corrupted.",1);
  0x8028 = @("Sure Start has determined that the BIOS settings policy store has been corrupted. Recovery of the BIOS setting policy store resulted in all BIOS settings reverting to factory defaults.",2);
  0x802a = @("The BIOS received a Manual Recovery command.",1);
  0x802b = @("Sure Start detected corrupted security critical BIOS policy/data settings and recovered from the backup copy in the Sure Start private flash.",1);
  0x802c = @("HP Sure Start detected a BIOS update operation completed.",1);
  0x802d = @("Sure Start detected a problem with and corrected part of the data storage overhead related to BIOS settings. No BIOS settings were changed.",1);
  0x802e = @("Sure Start has captured a back-up copy of the boot drive partition sector (Master Boot Record or GUID Partition Table).",0);
  0x802f = @("Sure Start has recovered the boot drive partition sector (Master Boot Record or GUID Partition Table) from the Sure Start back-up copy.",1);

  0x821e = @("Sure Start 'HP Firmware Runtime Intrusion Detection' has detected an unauthorized attempt to modify HP runtime firmware or disable HP runtime firmware protection mechanisms. System may be unstable until restarted.",1);
  0x821f = @("Sure Start 'HP Firmware Runtime Intrusion Detection' has detected an unauthorized attempt to modify HP runtime Firmware within main (DRAM) memory. System may be unstable until restarted.",1);
  0x8220 = @("Sure Start 'HP Firmware Runtime Intrusion Detection' has detected an attempt to execute unauthorized code within the HP System Management Mode portion of main (DRAM) memory. System may be unstable until restarted.",1);
  0x8221 = @("Sure Start 'HP Firmware Runtime Intrusion Detection' has detected an attempt to access unauthorized data outside of the HP System Management Mode portion of main (DRAM) memory. System may be unstable until restarted.",1);
  0x8222 = @("Sure Start 'HP Firmware Runtime Intrusion Detection' has detected an attempt to execute unauthorized code outside of the HP System Management Mode portion of main (DRAM) memory. System may be unstable until restarted.",1);
  0x8223 = @("Sure Start 'HP Firmware Runtime Intrusion Detection' test/demo more has been enabled.",1);
  0x8224 = @("Sure Start 'HP Firmware Runtime Intrusion Detection' test/demo more has been disabled.",0);
  0x8225 = @("Sure Start 'HP Firmware Runtime Intrusion Detection' has detected a problem which may indicate a security problem. System may be unstable until restarted.",1);

  0x831e = @("Sure Start 'HP Firmware Runtime Intrusion Detection' has detected an unauthorized change to HP runtime Firmware within main (DRAM) memory. System may be unstable until restarted.",1);
  0x831f = @("Sure Start 'HP Firmware Runtime Intrusion Detection' has detected an unauthorized change to the System Management Mode Base Address (SMBASE) configuration of the CPU. System may be unstable until restarted.",1);
  0x8320 = @("Sure Start 'HP Firmware Runtime Intrusion Detection' has detected an unauthorized change to critical Peripheral Component Interconnect (PCI) configuration settings within the core logic. System may be unstable until restarted.",1);
  0x8321 = @("Sure Start 'HP Firmware Runtime Intrusion Detection' stopped receiving status messages from the monitoring application. System may be unstable until restarted.",1);
  0x8322 = @("Sure Start 'HP Firmware Runtime Intrusion Detection' received an invalid manifest describing the memory space to be monitored during runtime. Runtime Intrusion Detection is disabled for this boot.",1);
  0x8323 = @("Sure Start 'HP Firmware Runtime Intrusion Detection' has experienced a general failure of the monitoring application. System may be unstable until restarted.",1);
  0x8324 = @("Sure Start 'HP Firmware Runtime Intrusion Detection' has detected an unauthorized change to critical Memory Mapped IO configuration settings within the core logic. System may be unstable until restarted.",1);

  0x841e = @("HP Secure Platform Management successfully initialized.",0);
  0x841f = @("An HP Secure Platform Management command was received that was rejected.",1);
  0x8420 = @("HP Secure Platform Management has been unconfigured.",0);
  0x8421 = @("The HP Secure Platform Management signing key was updated.",0);
  0x8422 = @("HP Hardware Enforced Protection has been activated via an HP Secure Platform Management command.",0);
  0x8423 = @("HP Hardware Enforced Protection has been deactivated via an HP Secure Platform Management command.",0);
  0x8424 = @("A problem has been detected with the HP Hardware Enforced Protection Agent and there is no assurance that the system remains in compliance with the guidelines that were set.  The system may be unstable until restarted.",1);
  0x8425 = @("An HP Secure Platform Management command has been received instructing the HP Hardware Enforced Protection Agent to suspend compliance checking and enforcement.",1);
  0x8426 = @("An HP Secure Platform Management command has been received instructing the HP Hardware Enforced Protection Agent to resume compliance checking and enforcement.",1);
  0x8427 = @("An HP Secure Platform Management command has been received instructing the HP Hardware Enforced Protection Agent to enter recovery mode.",1);
  0x8428 = @("The platform OS recovery process was started by the firmware.",0);
  0x8429 = @("The platform OS recovery process has successfully completed.",0);
  0x842a = @("The platform OS recovery process failed to complete successfully.",0);
  0x842b = @("The OS reported that HP Hardware Enforced Protection was not reinstalled.",0);
  0x842c = @("The system processed a service event which took action.",0);
  0x842d = @("HP Sure Run detected a problem.",1);

  0x851e = @("The Sure Start Secure Boot Keys Protection feature has been enabled.",0);
  0x851f = @("The Sure Start Secure Boot Keys Protection feature has been disabled.",0);
  0x8520 = @("Sure Start determined that the Secure Boot Keys were invalid and based on the recovery policy they have NOT been repaired.",2);
  0x8521 = @("The Secure Boot Keys have been repaired at the request of the user.",0);
  0x8522 = @("Sure Start determined that the Secure Boot Keys were invalid and they have been repaired automatically based on policy.",1);
  0x8523 = @("The BIOS has been configured to globally suppress the boot time prompts used by the BIOS to prevent remote entities from performing actions without user consent.",0);
  0x8524 = @("The BIOS has been configured to allow boot time prompts used to prevent remote entities from performing actions without user consent.",0);
  0x8525 = @("Sure Start has detected the Intel Management Engine (ME) is unable to start and has initiated the recovery process using an ME recovery firmware image stored on local disk or external recovery media.",1);
  0x8526 = @("Sure Start successfully recovered the Intel Management Engine firmware.",1);
  0x8527 = @("Sure Start was unable to recover the Intel Management Engine firmware.",1);
  0x8528 = @("Intel management engine firmware update failed.",1);
  0x8529 = @("Intel management engine firmware update succeeded.",0);
  0x852A = @("BIOS was unable to locate Intel management engine firmware binary needed to restore Intel management engine firmware ",1);

  0x861E = @("The HP Sure Start EpSC has found an integrity problem with the backup copy of Intel CSME bootloader firmware; the Intel CSME bootloader firmware integrity checking / recovery capability is no longer available.",2);
  0x861F = @("The HP Sure Start EpSC has found an integrity issue with the Intel CSME bootloader firmware.",1);
  0x8620 = @("The HP Sure Start EpSC has successfully captured a new backup of the most recent version of Intel CSME bootloader firmware and Intel CSME configuration.",0);
  0x8621 = @("The HP Sure Start EpSC has performed a recovery of the Intel CSME bootloader firmware and Intel CSME factory configuration. Administrative action may be required to ensure that all Intel CSME provided services are configured as desired.",2);
  0x8622 = @("The HP Sure Start EpSC detected that the system was unable to boot successfully after an Intel CSME firmware update; an attempt will be made to restore Intel CSME firmware.",2);
  0x8623 = @("HP Sure Start detected that the Intel CSME firmware file system (Intel CSME configuration) is corrupted; an attempt will be made to restore Intel CSME firmware and configuration to last known good state.",2);
  0x8624 = @("HP Sure Start detected that the Intel CSME failed to complete the boot initialization sequence immediately after the Intel CSME firmware update operation; an attempt will be made to restore Intel CSME firmware and configuration to last known good state.",2);
  0x8625 = @("Sure Start has detected the Intel Management Engine (ME) is unable to start and has initiated the recovery process using an ME recovery firmware image stored on local disk or external recovery media.",1);
  0x8626 = @("HP Sure Start has detected that the Intel CSME is in a disabled state due to corruption within the Intel CSME data region.",2);
  0x8627 = @("HP Sure Start unable to recover the Intel CSME firmware.",1);
  0x8628 = @("Intel CSME firmware update operation attempted by HP Sure Start failed due to error returned by Intel CSME firmware update interface.",1);
  0x8629 = @("HP Sure Start successfully updated primary Intel CSME firmware.",0);
  0x862A = @("HP Sure Start was unable to locate Intel CSME firmware binary needed to restore Intel CSME firmware.",1);
  0x862B = @("Intel CSME capsule update firmware package that was provided to HP Sure Start has failed the digital signature verification.",1);
  0x862D = @("HP Sure Start has detected an unexpected platform reset during an Intel CSME firmware update attempt.",1);
  0x862e = @("HP Sure Start EpSC detected an unauthorized Intel CSME state transition to manufacturing mode.",1);

  0x871E = @("HP BIOSSphere was unable to activate protection against malicious hardware impacting system operation.",2);
  0x871F = @("A device attempted to access memory that it was not allowed to access.",1);
  0x8720 = @("A device was given unrestricted access to memory.",0);
  0x8721 = @("A device was removed from the list of devices having unrestricted access to memory.",0);

  0x881E = @("An attempt was made to access the system locally and an incorrect PIN was entered multiple times resulting in the system forcing a reboot.",2);
  0x881F = @("An attempt to change a firmware setting was made with an invalid signature.",1);
  0x8820 = @("The local access key was changed.",0);
  0x8821 = @("HP Sure Admin - Enhanced BIOS Authentication Mode Local Access Key 1 was set.",0);
  0x8822 = @("HP Sure Admin - Enhanced BIOS Authentication Mode Local Access Key 1 was cleared.",0);
  0x8823 = @("Enhanced BIOS Authentication Mode was enabled.",0);
  0x8824 = @("Enhanced BIOS Authentication Mode was disabled.",0);
  0x8825 = @("The users Secure Platform Management PIN reminder was set.",0);
  0x8826 = @("The users Secure Platform Management PIN reminder was cleared.",0);
  0x8827 = @("The users Secure Platform Management PIN was requested.",0);

  0x891E = @("HP EpSC runtime intrusion detection - HP BIOS detected/blocked an illegal attempt to access the HP EpSC trusted interface from the OS.",1);
  0x891F = @("HP EpSC runtime intrusion detection - HP EpSC detected/blocked an illegal attempt to access the HP EpSC trusted interface from the OS.",1);
  0x8920 = @("HP EpSC runtime intrusion detection - An illegal attempt to write to EpSC code region of memory was detected and blocked.",2);
  0x8921 = @("HP EpSC runtime intrusion detection - An illegal attempt to execute from an EpSC data region of memory was detected and blocked.",2);
  0x8922 = @("Threat Hunter - A hidden process was found running in the OS.",1);

  0x8A1E = @("HP Tamper Lock - The system detected that the cover was opened.",1);
  0x8A1F = @("HP Tamper Lock - The user acknowledged a BIOS POST notification that the cover had been opened.",0);
  0x8A20 = @("HP Tamper Lock - The TPM was cleared due to cover removal based on current HP Tamper Lock policy settings.",0);

  0x8B1E = @("Cloud Management Infrastructure - A key was set.",0);
  0x8B1F = @("Cloud Management Infrastructure - A key was changed.",0);
  0x8B20 = @("Cloud Management Infrastructure - A key was removed.",0);
  0x8B21 = @("Cloud Management Infrastructure - This capability has been permanently disabled.",0);
  0x8C1E = @("Remote Device Management - Command was received to lock the system.",0);
  0x8C1F = @("Remote Device Management - Command was received to wipe the system.",0);
  0x8C20 = @("Remote Device Management - The system was successfully unlocked subsequent to being locked.",0);
  0x8C21 = @("Remote Device Management - This capability has been permanently disabled.",0);
  0x8D1E = @("Virtualization Based BIOS Protection - This capability has been disabled.",0);
  0x8D1F = @("Virtualization Based BIOS Protection - Detected and blocked an attempted access to protected resources.",1);
  0x8D20 = @("Virtualization Based BIOS Protection - Manual recovery mode trigger received.",1);
  0x8E1E = @("Immutable settings protection - This capability has been enabled.",0);
  0x8E1F = @("Immutable settings protection - This capability has been enabled.",1);
  0x8E20 = @("Immutable settings protection - Detected that a protected setting was corrupted and recovered the setting.",1);
}


function checkBitlocker ($bitlocker)
{
  if ($bitlocker -eq "ignore")
  {
    Write-Verbose "Skipping BitLocker check because BitLocker action = IGNORE"
    return $true
  }
  else {
    ($r,$dr) = isBootDriveBitlockerEncrypted
    Write-Verbose "Boot drive is BitLocker encrypted: $r"
    if ($r -eq $true)
    {
      if ($bitlocker -eq 'stop')
      {
        Write-Verbose ("BitLocker is on and BitLocker action = STOP")

        Write-Host -ForegroundColor Cyan "This system has BitLocker enabled."

        Write-Host -ForegroundColor Cyan "Do you want to suspend BitLocker for one reboot?"
        Write-Host -ForegroundColor Cyan "You can also specify '-BitLocker suspend' or '-BitLocker ignore' on the command line to skip this check."
        $response = Read-Host -Prompt "Type 'Y' to suspend BitLocker and anything else to abort. "
        if ($response -ne "Y") {
          Write-Verbose "User did not confirm BitLocker suspension - aborting."
          return $false
        }
        else { $bitlocker = 'suspend' }
      }


      if ($bitlocker -eq "suspend")
      {
        if (!$quiet) { Write-Host ("Suspending BitLocker on this system.") }
        Write-Verbose ("BitLocker is on and BitLocker action = SUSPEND")
        suspendBitlockerForOneReboot
        return $true
      }
      else {
        Write-Verbose ("Unknown BitLocker check option: $bitlocker")
        return $false
      }

    }
  }
}


function getAuditLogEntries ([ref]$buffer_out,[ref]$buffer_size,[ref]$records_count,[ref]$mi_result)
{
  $bs = $buffer_size.Value
  $rc = $records_count.Value
  $r = $mi_result.Value
  switch (Test-OSBitness) {
    32 { [DfmNativeBios]::get_audit_logs_32($buffer_out.Value,[ref]$bs,[ref]$rc,[ref]$r) }
    64 { [DfmNativeBios]::get_audit_logs_64($buffer_out.Value,[ref]$bs,[ref]$rc,[ref]$r) }
  }
  $buffer_size.Value = $bs
  $records_count.Value = $rc
  $mi_result.Value = $r
}




function isBootDriveBitlockerEncrypted ()
{
  [CmdletBinding()]
  param()

  $c = Get-BitLockerVolume | Where-Object VolumeType -EQ 'OperatingSystem'
  if (!$c -or $c.ProtectionStatus -eq "Off")
  {
    Write-Verbose ("No operating system drive found or drive is not encrypted")
    return ($false,$null)
  }
  Write-Verbose "Operating system $($c.MountPoint) is BitLocker encrypted."
  return ($true,$c)
}


function suspendBitlockerForOneReboot ()
{
  [CmdletBinding()]
  param()

  ($isEncrypted,$drive) = isBootDriveBitlockerEncrypted
  if ($isEncrypted) {
    Write-Verbose "Suspending BitLocker on $($drive.MountPoint) for one reboot."
    Suspend-BitLocker -MountPoint $drive.MountPoint -RebootCount 1
  }
  else
  {
    Write-Verbose 'No BitLocker operating system drives found to suspend.'
  }
}




<#
.SYNOPSIS
  This is a private command for internal use only. Returns the runtime architecture (64-bit or 32-bit).

.DESCRIPTION
  This is a private command for internal use only. This command returns 32 or 64, indicating the architecture of the running process.

.NOTES
  - When running 32-bit PowerShell on 64-bit systems, this will return 32.
  - This is a private command for internal use only
#>
function Test-OSBitness
{
  [CmdletBinding()]
  param()

  if ([IntPtr]::Size -eq 4)
  { 32 } else { 64 }
}

function formatLogTimestamp ([timestamp_t]$ts)
{
  try {
    Get-Date -Year $ts.Year -Month $ts.Month -Day $ts.Day -Hour $ts.hour -Minute $ts.minute -Second $ts.second -Millisecond 0
  }
  catch {
    return $null
  }
}

function formatLogEntryInHex ([int]$Status,[int]$MessageNumber,[timestamp_t]$TimeStamp,[int]$Source,[int]$Id,[int]$Severity,[int]$Data0,[int]$Data1,[int]$Data2,[int]$Data3,[int]$Data4)
{
  try {
    $StatusHex = '{0:X2}' -f $Status
    $MessageNumberHex = '{0:X2}' -f $MessageNumber
    $ts = Get-FormattedTime ($TimeStamp)
    $SourceHex = '{0:X2}' -f $Source
    $IdHex = '{0:X2}' -f $Id
    $SeverityHex = '{0:X2}' -f $Severity
    $Data0Hex = '{0:X2}' -f $Data0
    $Data1Hex = '{0:X2}' -f $Data1
    $Data2Hex = '{0:X2}' -f $Data2
    $Data3Hex = '{0:X2}' -f $Data3
    $Data4Hex = '{0:X2}' -f $Data4
    return $StatusHex + ':' + $MessageNumberHex + ':' + $ts + ':' + $SourceHex + ':' + $IdHex + ':' + $SeverityHex + ':' + $Data0Hex + ':' + $Data1Hex + ':' + $Data2Hex + ':' + $Data3Hex + ':' + $Data4Hex
  }
  catch {
    return $null
  }
}

function Get-FormattedTime ([timestamp_t]$ts)
{
  $second = [string]$ts.second
  $second = $second.PadLeft(2,'0')

  $minute = [string]$ts.minute
  $minute = $minute.PadLeft(2,'0')

  $hour = [string]$ts.hour
  $hour = $hour.PadLeft(2,'0')

  $day = [string]$ts.Day
  $day = $day.PadLeft(2,'0')

  $month = [string]$ts.Month
  $month = $month.PadLeft(2,'0')

  $year = [string]$ts.Year
  $year = $year.substring($year.Length - 2)

  return ($second + ':' + $minute + ':' + $hour + ':' + $day + ':' + $month + ':' + $year)
}

function resolvePath ([string]$path)
{
  $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($path)
}

function Test-HPPrivateBIOSUpdateOnlineModeIsSupported {
  [CmdletBinding()]
  param()

  try {
    $mi_result = 0
    switch (Test-OSBitness) {
      32 { $result = [DfmNativeBios]::online_flash_supported32([ref]$mi_result) }
      64 { $result = [DfmNativeBios]::online_flash_supported64([ref]$mi_result) }
    }
    Test-HPPrivateCustomResult -result 0x80000711 -Category 0x02 -mi_result $mi_result
  }
  catch [System.Management.Automation.MethodInvocationException]
  {
    displayInvocationException ($_.Exception)
  }

  return [bool]$result
}

function displayInvocationException ($exception)
{
  $bitness = Test-OSBitness
  Write-Verbose "Could not find support library for the current format: $($exception.Message)"
  throw "Could not call the support library. Please make sure the library dfmbios$bitness.dll is in the path."
}

function formatLogSeverity ([int]$severity)
{
  switch ($severity) {
    0 { "Info" }
    1 { "Warn" }
    2 { "Critical" }
    0xff { "Undefined" }
  }
}

function formatPowerstate ([powerstate_t]$state)
{
  switch ($state) {
    S0 { "S0" }
    S3 { "S3" }
    S4S5 { "S4/S5" }
    default { "Undefined" }
  }
}

function decodeLogData ($function,$byte1,$byte2,$byte3,$byte4,$byte5)
{
  switch ($function) {
    0x0323 {}
    0x0322 {}
    0x032f {}
    default { return $null }
  }
}

function getAdditionalData ([int]$source,[int]$id,[byte]$byte1,[byte]$byte2,[byte]$byte3,[byte]$byte4,[byte]$byte5)
{
  $result = "Not significant"
  switch ($source)
  {
    0x03 {
      switch ($id) {
        (0x22 -or 0x23) {
          $result = "Writing BIOS $byte1.$byte2.$byte3.$byte4 $byte5"
        }
        0x2f {
          $result = "Label: {0}{1}{2}{3}" -f [char]$byte2,[char]$byte3,[char]$byte4,[char]$byte5
        }
      }
    }
  }
  return $result
}

function formatEventSource ([int]$source) {
  switch ($source) {
    0x00 { "EC ROM ($source)" }
    0x01 { "RTOS ($source)" }
    0x02 { "EC Task ($source)" } # EC Task
    0x03 { "HP Sure Start ($source)" } # FB EC TASK
    0x80 { "General BIOS Messages ($source)" }
    0x81 { "Secure HDD Erase ($source)" }
    0x82 { "HP Sure Start Runtime Intrusion Detection for Intel ($source)" } # SS3 from BIOS
    0x83 { "HP Sure Start Runtime Intrusion Detection for AMD ($source)" } # SS3 from PCP
    0x84 { "HP Secure Platform Management ($source)" }
    0x85 { "HP Sure Start Gen4 ($source)" }
    0x86 { "HP Sure Start resilience for Intel CSME ($source)" }
    0x87 { "HP DMA Protection ($source)" }
    0x88 { "HP Sure Admin ($source)" }
    0x89 { "HP EpSC Runtime Intrusion Detection ($source)" }
    0x8A { "HP Tamper Lock ($source)" }
    0x8B { "Cloud Management Infrastructure ($source)" }
    0x8C { "Remote Device Management ($source)" }
    0x8D { "Virtualization Based BIOS Protection ($source)" }
    0x8E { "Immutable Settings Protection ($source)" }
    default {
      Write-Verbose ("An unknown source ID was found: $source")
      "Reserved ($source)"
    }
  }
}

function makeCredential ($data)
{

  [bios_credential_t]$cred = New-Object bios_credential_t

  if (-not $data) {
    $cred.authentication = [authentication_t]::auth_t_anonymous
  }
  else
  {
    $cred.authentication = [authentication_t]::auth_t_password
    $c = New-Object authentication_data_t
    $c.Password = $data
    $c.password_size = $data.Length
    $cred.Data = $c
  }
  $cred
}



function getLogEntry ([uint32]$source,[uint32]$id,[int]$index)
{
  [int]$code = $id -bor ($source -shl 8)
  $result = "Undefined log entry $id from source $source."
  try {
    $result = $msgs[$code][$index] } catch {
    Write-Verbose ("No entry for source=$source and id=$id, using generic description");
  }
  return [string]$result
}

function getImageInformation ($filename)
{

  if (Test-Path $filename) { $info = (Get-Item $filename) }
  else {
    throw "Logo bitmap file $file not found."
  }

  [psobject]$result = New-Object PSOBJECT
  try {
    $image = New-Object -ComObject Wia.ImageFile
    $image.LoadFile($info.FullName)
  }
  catch [System.ArgumentException]{
    Write-Verbose $_.Exception
    throw "Could not load '$file' please make sure this is a valid JPEG file"
  }

  Write-Verbose "This picture is $($image.width) x $($image.height)"
  Write-Verbose "This picture is $($info.length) bytes"

  $result |
  Add-Member -MemberType NoteProperty -Name FullName -Value $info.FullName -Passthru |
  Add-Member -MemberType NoteProperty -Name Size -Value $info.Length -Passthru |
  Add-Member -MemberType NoteProperty -Name Width -Value $image.Width -Passthru |
  Add-Member -MemberType NoteProperty -Name Height -Value $image.Height -Passthru |
  Add-Member -MemberType NoteProperty -Name Depth -Value $image.pixeldepth -Passthru |
  Add-Member -MemberType NoteProperty -Name Xdpi -Value $image.horizontalresolution -Passthru |
  Add-Member -MemberType NoteProperty -Name Ydpi -Value $image.verticalresolution -Passthru
}



<#
.SYNOPSIS
  Retrieves firmware log entries

.DESCRIPTION
  This command retrieves an array of firmware log entries. These logs are HP specific and are generated by various HP firmware subsystems.

.PARAMETER Numeric
  If specified, the output displays the log entries as raw values, which is often useful for debugging or communicating with HP. Otherwise, the script will attempt to interpret the logs and display friendly text.

.EXAMPLE
  $logs = Get-HPFirmwareAuditLog -numeric

.NOTES
  - Requires HP BIOS with firmware log support
  - This command requires elevated privileges.
#>
function Get-HPFirmwareAuditLog {
  [CmdletBinding(HelpUri = "https://developers.hp.com/hp-client-management/doc/Get-HPFirmwareAuditLog")]
  param([switch]$Numeric)


  if (-not (Test-IsElevatedAdmin)) {
    throw [System.Security.AccessControl.PrivilegeNotHeldException]"elevated administrator"
  }

  $buffer_size = 0
  $buffer_out = $null
  $records_count = 0
  $mi_result = 0

  Write-Verbose "Querying for number of records."
  try {
    $result = getAuditLogEntries -buffer_out ([ref]$buffer_out) -buffer_size ([ref]$buffer_size) -records_count ([ref]$records_count) -mi_result ([ref]$mi_result)
  }
  catch [System.Management.Automation.MethodInvocationException]
  {
    displayInvocationException ($_.Exception)
  }

  Test-HPPrivateCustomResult -result $result -mi_result $mi_result -Category 0x01

  if ($records_count -eq 0)
  {
    Write-Verbose "There are no records to retrieve."
    return "No records."
  }
  Write-Verbose "Found $records_count records."
  $buffer_out = [bios_log_entry_t[]]::new($records_count)

  try {
    $result = getAuditLogEntries -buffer_out ([ref]$buffer_out) -buffer_size ([ref]$buffer_size) -records_count ([ref]$records_count) -mi_result ([ref]$mi_result)

    <#
    switch (Test-OSBitness) {
      32 { $result = [DfmNativeBios]::get_audit_logs_32($buffer_out,[ref]$buffer_size,[ref]$records_count,[ref]$mi_result) }
      64 { $result = [DfmNativeBios]::get_audit_logs_64($buffer_out,[ref]$buffer_size,[ref]$records_count,[ref]$mi_result) }
    }
    #>
  }
  catch [System.Management.Automation.MethodInvocationException]
  {
    displayInvocationException ($_.Exception)
  }

  Test-HPPrivateCustomResult -result $result -mi_result $mi_result -Category 0x01
  Write-Verbose "Received $records_count records"

  if (-not $numeric.IsPresent) {
    $buffer_out | Select-Object -Property `
      message_number,`
      @{ Name = "severity"; Expression = { formatLogSeverity (getLogEntry -Source $_.source_id -Id $_.event_id -Index 1) } },`
      @{ Name = "system_state_at_event"; Expression = { formatPowerstate ($_.system_state_at_event) } },`
      @{ Name = "source_id"; Expression = { formatEventSource ($_.source_id) } },`
      event_id,`
      timestamp_is_exact,`
      @{ Name = "timestamp"; Expression = { formatLogTimestamp ($_.timestamp) } },`
      @{ Name = "description"; Expression = { getLogEntry -Source $_.source_id -Id $_.event_id -Index 0 -Numeric $numeric.IsPresent } },`
      @{ Name = "raw_event_data"; Expression = { (formatLogEntryInHex `
        -Status $_.Status `
        -MessageNumber $_.message_number `
        -timestamp $_.timestamp `
        -Source $_.source_id `
        -Id $_.event_id `
        -Severity $_.severity `
        -Data0 $_.data_0 `
        -Data1 $_.data_1 `
        -Data2 $_.data_2 `
        -Data3 $_.data_3 `
        -Data4 $_.data_4) }
      }
  }
  else
  {
    $buffer_out | Select-Object -Property `
      message_number,`
        @{ Name = "severity"; Expression = { [int]$_.severity } },`
        @{ Name = "system_state_at_event"; Expression = { [int]$_.system_state_at_event } },`
        source_id,`
        event_id,`
        timestamp_is_exact,`
        @{ Name = "timestamp"; Expression = { formatLogTimestamp ($_.timestamp) } },`
        @{ Name = "raw_event_data"; Expression = {(formatLogEntryInHex `
          -Status $_.Status `
          -MessageNumber $_.message_number `
          -timestamp $_.timestamp `
          -Source $_.source_id `
          -Id $_.event_id `
          -Severity $_.severity `
          -Data0 $_.data_0 `
          -Data1 $_.data_1 `
          -Data2 $_.data_2 `
          -Data3 $_.data_3 `
          -Data4 $_.data_4) }
        }
  }
}


<#
.SYNOPSIS
  Sets the logo on reboot  

.DESCRIPTION
  This command sets the boot logo that is seen after computer POST and before the OS takes over. The default logo is the HP logo, but companies may wish to customize it with their own enterprise or workgroup logo.

  Please note that the file format has specific restrictions. See the -File parameter for more information.

.NOTES
  - Requires HP BIOS.
  - This command requires elevated privileges.
  - Use single quotes around the password to prevent PowerShell from interpreting special characters in the string.


.PARAMETER File
  Specifies the file to use as the logo. The file must follow the below restrictions:
    1. Must be JPEG
    2. Resolution may not be higher than 1024x768
    3. File size may not be larger than 32751 bytes.


.PARAMETER Password
  Specifies the BIOS setup password, if any 

.EXAMPLE
    Set-HPFirmwareBootLogo -file myfile.jpg

.LINK
  [Clear-HPFirmwareBootLogo](Clear-HPFirmwareBootLogo)

.LINK
  [Get-HPFirmwareBootLogoIsActive](Get-HPFirmwareBootLogoIsActive)

.NOTES
  - Not currently supported in Windows PE.
  - Requires HP BIOS
  - This command requires elevated privileges.
  - Due to a BIOS limitation, this command will not succeed if HP Sure Admin is enabled. 
#>
function Set-HPFirmwareBootLogo
{
  [CmdletBinding(HelpUri = "https://developers.hp.com/hp-client-management/doc/Set-HPFirmwareBootLogo")]

  param(
    [Parameter(Mandatory = $true,Position = 0)] [string]$File,
    [Parameter(Mandatory = $false,Position = 1)] [string]$Password = $null)

  if (-not (Test-IsElevatedAdmin)) {
    throw [System.Security.AccessControl.PrivilegeNotHeldException]"elevated administrator"
  }

  [bios_credential_t]$cred = makeCredential ($password)
  $max_size = (32768 - 16 - 1)
  $mi_result = 0

  if ($password -ne $null)
  {
    $cred.authentication = [authentication_t]::auth_t_password
    $cred.Data.Password = $password
    $cred.Data.password_size = $password.Length
  }

  $info = getImageInformation ($file)

  if (($info.Width -gt 1024) -or ($info.Height -gt 768) -or ($info.Size -gt $max_size))
  {
    Write-Verbose ("Validation error:")
    Write-Verbose (" File size: $size")
    Write-Verbose (" File resolution: $width x $height")
    throw ("File is larger than $max_size or has a greater resolution than 1024x768")
  }

  try {
    switch (Test-OSBitness) {
      32 { $result = [DfmNativeBios]::set_enterprise_logo32($info.FullName,[ref]$cred,[ref]$mi_result) }
      64 { $result = [DfmNativeBios]::set_enterprise_logo64($info.FullName,[ref]$cred,[ref]$mi_result) }
    }
  }
  catch [System.Management.Automation.MethodInvocationException]
  {
    displayInvocationException ($_.Exception)
  }
  Test-HPPrivateCustomResult -result $result -mi_result $mi_result -Category 0x02

}


<#
.SYNOPSIS
  Checks if a custom logo is currently active

.DESCRIPTION
  This command returns $true if a custom logo was previously configured via the Set-HPFirmwareBootLogo command. Returns $false otherwise. 

.NOTES
  - Requires HP BIOS
  - This command requires elevated privileges.

.EXAMPLE
    $isactive = Get-HPFirmwareBootLogoIsActive

.LINK
  [Clear-HPFirmwareBootLogo](Clear-HPFirmwareBootLogo)

.LINK
  [Set-HPFirmwareBootLogo](Set-HPFirmwareBootLogo)



#>
function Get-HPFirmwareBootLogoIsActive
{
  [CmdletBinding(HelpUri = "https://developers.hp.com/hp-client-management/doc/Get-HPFirmwareBootLogoIsActive")]
  param()
  if (-not (Test-IsElevatedAdmin)) {
    throw [System.Security.AccessControl.PrivilegeNotHeldException]"elevated administrator"
  }
  $state = 0
  $installed = 0
  $mi_error = 0

  try {
    switch (Test-OSBitness) {
      32 { $result = [DfmNativeBios]::query_enterprise_logo32([ref]$installed,[ref]$state,[ref]$mi_error) }
      64 { $result = [DfmNativeBios]::query_enterprise_logo64([ref]$installed,[ref]$state,[ref]$mi_error) }
    }
  }
  catch [System.Management.Automation.MethodInvocationException]
  {
    displayInvocationException ($_.Exception)
  }

  Test-HPPrivateCustomResult -result $result -mi_result $mi_error -Category 0x02
  Write-Verbose ("Flash is in progress: $state")
  Write-Verbose ("Logo in use: $installed")
  $installed -eq 1
}

<#
.SYNOPSIS
  Removes any active custom boot logo

.DESCRIPTION
  This command removes any custom boot logo and reverts the boot logo back to the HP logo. 

.PARAMETER password
  Specifies the BIOS setup password, if any. Use single quotes around the password to prevent PowerShell from interpreting special characters in the string.

.EXAMPLE
  Clear-HPFirmwareBootLogo -file myfile.jpg

.LINK
  [Set-HPFirmwareBootLogo](Set-HPFirmwareBootLogo)

.LINK
  [Get-HPFirmwareBootLogoIsActive](Get-HPFirmwareBootLogoIsActive)

.NOTES
  - Requires HP BIOS
  - This command requires elevated privileges.
  - Due to a BIOS limitation, this command will not succeed when HP Sure Admin is enabled.

#>
function Clear-HPFirmwareBootLogo
{
  [CmdletBinding(HelpUri = "https://developers.hp.com/hp-client-management/doc/Clear-HPFirmwareBootLogo")]

  param([Parameter(Mandatory = $false,Position = 0)] [string]$Password = $null)
  if (-not (Test-IsElevatedAdmin)) {
    throw [System.Security.AccessControl.PrivilegeNotHeldException]"elevated administrator"
  }

  $mi_result = 0
  $cred = makeCredential ($password)

  try {
    switch (Test-OSBitness) {
      32 { $result = [DfmNativeBios]::clear_enterprise_logo32([ref]$cred,[ref]$mi_result) }
      64 { $result = [DfmNativeBios]::clear_enterprise_logo64([ref]$cred,[ref]$mi_result) }
    }
  }
  catch [System.Management.Automation.MethodInvocationException]
  {

    displayInvocationException ($_.Exception)
  }

  Test-HPPrivateCustomResult -result $result -mi_result $mi_result -Category 0x02
}



<#
.SYNOPSIS
  Updates the system firmware from a capsule or BIOS binary file

.DESCRIPTION
  This command updates the system firmware on the current platform. The update must be provided as a BIN file and can be obtained via the [Get-HPBIOSUpdates](https://developers.hp.com/hp-client-management/doc/Get-HPBiosUpdates) command.
  If HP Sure Admin is enabled, a payload file should be provided instead of a password.

  Online Mode uses Seamless Firmware Update Service. Seamless Firmware Update Service updates the BIOS in the background while the operating system is running (no authentication needed). 2022 and newer HP computers with Intel processors support Seamless Firmware Update Service.
  Offline Mode updates the BIOS on reboot and requires authentication (password or payload).

.PARAMETER File
  Specifies the firmware update binary (.BIN) file. If the filename does not follow the pattern 'U70_010101.bin', the -FilenameHint parameter should be specified.

.PARAMETER PayloadFile
  Specifies the payload file to authorize firmware update. Refer to the New-HPSureAdminFirmwareUpdatePayload command for information on how to generate the payload file.

.PARAMETER Payload
  Specifies the payload to authorize firmware update. Refer to the New-HPSureAdminFirmwareUpdatePayload command for information on how to generate the payload.

.PARAMETER Password
  Specifies the BIOS setup password, if any. Use single quotes around the password to prevent PowerShell from interpreting special characters in the string.

.PARAMETER Quiet
  If specified, this command will suppress non-essential messages during execution. 

.PARAMETER BitLocker
  Specifies the behavior to the BitLocker check prompt (if any). The value must be one of the following values:
  - stop: (default option) stops execution if BitLocker is detected but not suspended, and prompts
  - ignore: skips the BitLocker check
  - suspend: suspends BitLocker if active and continues with execution 

.PARAMETER Force
  If specified, this command will force the BIOS update even if the target BIOS is already installed. 

.PARAMETER FilenameHint
  Specifies the original file name without the .bin extension if using a file name other than the original file name. Alias -filename_hint. Some older generations of platforms require that the filename of the BIOS update be in a specific format (e.g.: 'U70_010101'). 
  If this parameter is not specified, this command will extract the file name from the -File parameter. However, if it does not match the required format on platforms that require a specific format, this command may fail. 
  If the system does not require a specific format (not required on most recent systems), this parameter might be ignored.

.PARAMETER Offline
  If specified, this command selects the offline mode to flash the BIOS instead of the default online mode. If specified, the actual flash will only occur on reboot at pre-OS environment. Please note that offline mode is selected by default when downgrading the BIOS. Offline mode requires authentication, so either a Password or a PayloadFile should be specified.

.PARAMETER NoWait
  If specified, the script will not wait for the online flash background task to finish. If the user reboots the PC during the online flash, the update will complete only after reboot.

.EXAMPLE
  Update-HPFirmware -File bios.bin -Password 'mysecret' -FilenameHint 'U70_010101'

.EXAMPLE
  Update-HPFirmware -File U70_010101.bin -NoWait

.EXAMPLE
  Update-HPFirmware -File U70_010101.bin -Offline

.EXAMPLE
  Update-HPFirmware -File bios.bin -PayloadFile PayloadFile.dat -FilenameHint 'U70_010101'

.NOTES
  - Requires HP BIOS.
  - Requires 64-bit PowerShell (not supported under 32-bit PowerShell).
  - UEFI boot mode is required; legacy mode is not supported.
  - This command requires elevated privileges.

  **WinPE notes**

  - Use '-BitLocker ignore' when using this command in WinPE because BitLocker checks are not applicable in Windows PE.
  - Requires that the WInPE image is built with the WinPE-SecureBootCmdlets.cab component.

#>
function Update-HPFirmware {
  [CmdletBinding(HelpUri = "https://developers.hp.com/hp-client-management/doc/Update-HPFirmware")]
  param(
    [Parameter(ParameterSetName = "Password",Mandatory = $false,Position = 0)]
    [string]$Password,

    [Parameter(ParameterSetName = "PayloadFile",Mandatory = $true,Position = 0)]
    [System.IO.FileInfo]$PayloadFile,

    [Parameter(ParameterSetName = "Payload",Mandatory = $true,Position = 0)]
    [string]$Payload,

    [ValidateScript({ if (-not ($_ | Test-Path)) { throw "Firmware file '$_' cannot be accessed." } return $true })]
    [Parameter(ParameterSetName = "Password",Mandatory = $true,Position = 1)]
    [Parameter(ParameterSetName = "PayloadFile",Mandatory = $true,Position = 1)]
    [Parameter(ParameterSetName = "Payload",Mandatory = $true,Position = 1)]
    [System.IO.FileInfo]$File,

    [Parameter(ParameterSetName = "Password",Mandatory = $false,Position = 2)]
    [Parameter(ParameterSetName = "PayloadFile",Mandatory = $false,Position = 2)]
    [Parameter(ParameterSetName = "Payload",Mandatory = $false,Position = 2)]
    [switch]$Quiet,

    [ValidateSet('stop','ignore','suspend')]
    [Parameter(ParameterSetName = "Password",Mandatory = $false,Position = 3)]
    [Parameter(ParameterSetName = "PayloadFile",Mandatory = $false,Position = 3)]
    [Parameter(ParameterSetName = "Payload",Mandatory = $false,Position = 3)]
    [string]$BitLocker = 'stop',

    [Alias("filename_hint")]
    [ValidateScript({ 
      if (($PSItem -match '^[A-Z][0-9]{2}_[0-9]{4}$') -or ($PSItem -match '^[A-Z][0-9]{2}_[0-9]{6}$') -or ($PSItem -match '^[A-Z][0-9]{2}_[0-9]{8}$'))
    { return $true } 
    throw "Filename hint '$_' does not match expected format of '<biosFamily>_<targetBiosVersion>' where targetBiosVersion must have 4 or 6 or 8 digits."})]
    [Parameter(ParameterSetName = "Password",Mandatory = $false,Position = 4)]
    [Parameter(ParameterSetName = "PayloadFile",Mandatory = $false,Position = 4)]
    [Parameter(ParameterSetName = "Payload",Mandatory = $false,Position = 4)]
    [string]$FilenameHint,

    [Parameter(ParameterSetName = "Password",Mandatory = $false,Position = 5)]
    [Parameter(ParameterSetName = "PayloadFile",Mandatory = $false,Position = 5)]
    [Parameter(ParameterSetName = "Payload",Mandatory = $false,Position = 5)]
    [switch]$Force,

    [Parameter(ParameterSetName = "Password",Mandatory = $false,Position = 6)]
    [Parameter(ParameterSetName = "PayloadFile",Mandatory = $false,Position = 6)]
    [Parameter(ParameterSetName = "Payload",Mandatory = $false,Position = 6)]
    [switch]$Offline,

    [Parameter(ParameterSetName = "Password",Mandatory = $false,Position = 7)]
    [Parameter(ParameterSetName = "PayloadFile",Mandatory = $false,Position = 7)]
    [Parameter(ParameterSetName = "Payload",Mandatory = $false,Position = 7)]
    [switch]$NoWait
  )

  Test-HPFirmwareFlashSupported -CheckPlatform
  $resolvedFile = resolvePath ($file)

  Write-Verbose 'Preparing BIOS update'
  Write-Verbose "Update file is: $resolvedFile"

  [byte[]]$authorization = $null
  $authorizationLength = 0
  if ($PSCmdlet.ParameterSetName -eq 'PayloadFile' -Or $PSCmdlet.ParameterSetName -eq 'Payload') {
    if ($PSCmdlet.ParameterSetName -eq 'PayloadFile') {
      $payload = Get-Content -Path $PayloadFile -Encoding UTF8
    }
    [PortableFileFormat]$portable = ConvertFrom-Json -InputObject $payload

    if ($portable.purpose -ne "hp:sureadmin:firmwareupdate") {
      throw "The payload should be generated by New-HPSureAdminFirmwareUpdatePayload function"
    }

    $data = [System.Text.Encoding]::UTF8.GetString($portable.Data) | ConvertFrom-Json
    [byte[]]$authorization = $data.Authorization | ConvertFrom-Json
    $authorizationLength = $authorization.Length
  }

  $blenabled = checkBitlocker ($bitlocker)
  if ($blenabled -eq $false) {
    Write-Verbose "Aborting due to BitLocker issue"
    return
  }

  $cred = makeCredential ($password)

  if (-not $FilenameHint) {
    $filenameHintInternal = [io.path]::GetFileNameWithoutExtension($file)
    
    # if two extra digits are found in the -File parameter, remove them from the filenameHintInternal variable
    if ($filenameHintInternal.Length -eq 12) {
      $filenameHintInternal = $filenameHintInternal.substring(0, 10)
    }

    Write-Verbose "Extracting filenameHint from file: '$filenameHintInternal'"
  }
  else {
    $filenameHintInternal = $FilenameHint
    Write-Verbose "Caller gives a filename hint of '$filenameHintInternal'"
  }

  try {
    # Reconstruct the file name for the current BIOS and use it to compare
    # with the target BIOS file name. This is used as a 'best effort' check.
    $ver,$fam = (Get-HPBIOSVersion -IncludeFamily).Replace(".","").Split()
    $ver = $ver.Replace(".","").PadLeft(6,'0')
    $biosVersion = "$($fam)_$($ver)"
  }
  catch {
    Write-Verbose "Could not construct file name for the currently installed BIOS: $($_.Exception.Message)"
    $biosVersion = ""
    $ver = $null
  }

  $isValidBiosVersion = $biosVersion -match '^[A-Z][0-9]{2}_[0-9]{4,6}$'
  if (-not $isValidBiosVersion) {
    throw "Could not construct file name for the currently installed BIOS: $biosVersion"
  }

  if (-not $Force.IsPresent -and ($filenameHintInternal -eq $biosVersion)) {
    Write-Host "This system is already running BIOS version $(Get-HPBIOSVersion)"
    Write-Host -ForegroundColor Cyan "Use '-Force' on the command line to proceed anyway."
    return
  }

  $Callback = {
    param(
      [int32]$Location,
      [int32]$Value1,
      [int32]$Value2,
      [int32]$Status
    )

    if (-not $quiet.IsPresent) {
      $activityTitle = "Updating system firmware"
      switch ($location)
      {
        1 { Write-Progress -Activity $activityTitle -CurrentOperation "Beginning flash process" -PercentComplete 0 }
        2 {
          $progress = ($Value1 * 100) / $Value2
          Write-Progress -Activity $activityTitle -CurrentOperation "Copying firmware" -PercentComplete $progress
        }
        3 { Write-Progress -Activity $activityTitle -CurrentOperation "Completing operation" -PercentComplete 100 }
        4 {
          $progress = ($Value1 * 100) / $Value2
          Write-Progress -Activity $activityTitle -CurrentOperation "Waiting for the BIOS to process the file" -PercentComplete $progress
        }
        10 { Write-Progress -Activity $activityTitle -CurrentOperation "Operation complete" -PercentComplete 100 -Completed }
        default { Write-Verbose "Unknown status received $location" }
      }
    }
  } -as [ProgressCallback]

  $efi_path = Get-EFIPartitionPath -FixedOnly

  # Online mode isn't supported when downgrading the BIOS
  # Using filenameHint to determine if it is a downgrade or not
  $offlineMode = $false

  # some bin file names have an extra two zeroes at the end of the BIOS version number i.e. S02_02160000.bin instead of S02_021600.bin or S02_0216.bin 
  # workaround: if 8 digit version was given in the -FilenameHint parameter, drop the last two digits in filenameHintInternal just like we do if no -FilenameHint parameter was given and two extra digits were found in the filename for the BIOS version
  # warning: this is a weak workaround, but it is the best we can do to not confuse the user if they give a filename hint that is exactly the same as the name of the bin file 
  if($filenameHintInternal -match '^[A-Z][0-9]{2}_[0-9]{8}$'){
    $filenameHintInternal = $filenameHintInternal.Substring(0, $filenameHintInternal.Length - 2)
  }

  # note: if filename hint given through FileNameHint parameter has 5 digits or 7 digits, bios version comparison might not be valid. In theory, 5 digits or 7 digits target bios versions should never get through to here 
  # because of the ValidateScript() for the FilenameHint parameter. 
  # If it does, the command will continue with a warning just like how it does if filename hint (determined from -File parameter or given in -FilenameHint parameter) does not match regex pattern '^[A-Z][0-9]{2}_[0-9]{4}$' or '^[A-Z][0-9]{2}_[0-9]{6}$'
  # Set-HPPrivateFlashHPDevice should fail if a valid filename hint was necessary for the update to be successful (some platforms require a specific format to be given in the filenamehint). 
  $isValidHint = $filenameHintInternal -match '^[A-Z][0-9]{2}_[0-9]{4}$' -or $filenameHintInternal -match '^[A-Z][0-9]{2}_[0-9]{6}$'
  if ($isValidHint) {
    $targetVer = $filenameHintInternal.Split('_')[1]

    if ($targetVer -and $ver) {
      # if the current BIOS version is greater than or equal to the target BIOS version, then offline mode is selected
      if ($ver.TrimStart('0') -ge $targetVer.TrimStart('0')) {
        Write-Verbose "Offline mode selected based on the filename hint."
        $offlineMode = $true
      }
    }
    else {
      $isValidHint = $false
    }
  }

  if (-not $isValidHint) {
    Write-Warning "Cannot parse the filename $filenameHintInternal. This parameter is used to determine if it is a BIOS downgrade or upgrade."
  }

  $onlineModeIsSupported = Test-HPPrivateBIOSUpdateOnlineModeIsSupported
  if ($Offline.IsPresent -or -not $onlineModeIsSupported) {
    Write-Verbose "Online mode supported: $onlineModeIsSupported."
    $offlineMode = $true
  }

  if ($offlineMode -and ((Get-HPBIOSSetupPasswordIsSet) -or (Get-HPPrivateSecurePlatformIsProvisioned)) -and -not $Password -and -not $PayloadFile -and -not $Payload) {
    throw "Offline mode is selected. This mode requires authentication so either a Password or PayloadFile should be specified."
  }

  Set-HPPrivateFlashHPDevice -ResolvedFile $resolvedFile -Cred $cred -Callback $Callback -FilenameHint $filenameHintInternal -Efi_path $efi_path -Authorization $authorization -AuthorizationLength $authorizationLength -Offline $offlineMode -NoWait $NoWait.IsPresent -Verbose:$VerbosePreference

  if (-not $quiet.IsPresent) {
    Write-Host -ForegroundColor Cyan "Firmware image has been deployed. The process will continue after reboot."
  }
}

<#
.SYNOPSIS
  This is a private command for internal use only

.DESCRIPTION
  This is a private command for internal use only

.EXAMPLE

.NOTES
  - This is a private command for internal use only
#>
function Set-HPPrivateFlashHPDevice {
  [CmdletBinding()]
  param(
    $ResolvedFile,
    $Cred,
    $Callback,
    $FilenameHint,
    $Efi_path,
    $Authorization,
    $AuthorizationLength,
    $Offline,
    $NoWait
  )

  try {
    $mi_result = 0
    switch (Test-OSBitness) {
      32 { $result = [DfmNativeBios]::flash_hp_device32([string]$ResolvedFile,[ref]$Cred,[ref]$mi_result,$Callback,$FilenameHint,$Efi_path,$Authorization,$AuthorizationLength,[bool]$Offline,[bool]$NoWait) }
      64 { $result = [DfmNativeBios]::flash_hp_device64([string]$ResolvedFile,[ref]$Cred,[ref]$mi_result,$Callback,$FilenameHint,$Efi_path,$Authorization,$AuthorizationLength,[bool]$Offline,[bool]$NoWait) }
    }
    Test-HPPrivateCustomResult -result $result -Category 0x02 -mi_result $mi_result
  }
  catch [System.Management.Automation.MethodInvocationException]
  {
    displayInvocationException ($_.Exception)
  }

  Test-HPPrivateCustomResult -result 0x80000711 -mi_result $result -Category 0x02
}


<#
.SYNOPSIS
  This is a private command for internal use only

.DESCRIPTION
  This is a private command for internal use only

.EXAMPLE

.NOTES
  - This is a private command for internal use only
#>
function Set-HPPrivateFirmwareUpdatePayload {
  [CmdletBinding()]
  param(
    [Parameter(ParameterSetName = 'Payload',Position = 0,Mandatory = $true,ValueFromPipeline = $true)]
    [string]$Payload
  )

  [PortableFileFormat]$portable = ConvertFrom-Json -InputObject $payload
  if ($portable.purpose -ne "hp:sureadmin:firmwareupdate") {
    throw "The payload should be generated by New-HPSureAdminFirmwareUpdatePayload function"
  }

  $data = [System.Text.Encoding]::UTF8.GetString($portable.Data) | ConvertFrom-Json
  $params = @{
    File = resolvePath ($data.FileName)
    Payload = $Payload
  }
  if ($data.Quiet -eq $True) {
    $params.Quiet = $data.Quiet
  }
  if ($data.Force -eq $True) {
    $params.Force = $data.Force
  }
  if ($data.bitlocker) {
    $params.BitLocker = $data.bitlocker
  }

  if ([System.IO.File]::Exists($params.file) -eq $true) {
    Write-Verbose "File $($params.File) was found, calling Update-HPFirmware"
    Update-HPFirmware @params
  }
  else {
    Write-Verbose "File $($params.File) was not found, you can call Update-HPFirmware manually"
  }
}

<#
.SYNOPSIS
  Checks if firmware updates via UEFI mode are supported on the current platform

.DESCRIPTION
  This command checks if firmware updates in UEFI mode are supported on the current platform and throws an exception if the current platform does not meet the minimum requirements for flashing.

.EXAMPLE
    Test-HPFirmwareFlashSupported

.NOTES
  - This command requires elevated privileges.
  - UEFI Mode and proper flash support in the BIOS (normally 2017 or later platforms) are required for flashing. 
#>
function Test-HPFirmwareFlashSupported
{
  [CmdletBinding(HelpUri = "https://developers.hp.com/hp-client-management/doc/Test-HPFirmwareFlashSupported")]
  param(
    [Parameter(Mandatory = $false,Position = 1)] [switch]$CheckPlatform
  )
  [int]$major = [environment]::OSVersion.Version.Major
  [int]$release = (Get-ItemProperty -Path Registry::"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ReleaseId
  [int]$result = 0

  if (-not (Test-IsElevatedAdmin)) {
    throw [System.Security.AccessControl.PrivilegeNotHeldException]"elevated administrator"
  }

  if ($checkplatform.IsPresent) {
    Write-Verbose "Checking UEFI mode"
    if ((Get-HPDeviceBootInformation).Mode -ne "UEFI")
    {
      Write-Verbose "Mode $((Get-HPDeviceBootInformation).Mode) is not supported."
      throw [System.Management.Automation.RuntimeException]"This cmdlet only supported Windows 10 UEFI mode."
    }

    Write-Verbose "Making sure BIOS update is not locked"
    try {
      if ((Get-HPBIOSSettingValue "Lock BIOS Version") -ne "Disable")
      {
        Write-Verbose "Lock BIOS Version is set; flash will probably fail"
        throw [System.Management.Automation.RuntimeException]"You cannot flash while 'Lock BIOS Version' is enabled."
      }
    } catch [System.InvalidOperationException],[System.Management.Automation.ItemNotFoundException]{
      Write-Verbose "This system does not appear to have a Lock BIOS Version setting - ignoring."
    }
  }

  Write-Verbose "All flash checks passed"

}


<#
.SYNOPSIS
  Creates a password file compatible with HP BIOS Configuration Utility (BCU)

.DESCRIPTION
  This command creates a password file that is compatible with the HP BIOS Configuration Utility (BCU). The command is roughly equivalent to running the HpqPswd tool with the following arguments:

  hpqpswd /s /p"password" /f"outfile"


.PARAMETER password
  Specifies the password to encode into the target file

.PARAMETER outfile
  Specifies the file to create. If not specified, this command will attempt to create a file in the current directory named 'password.bin'.

.EXAMPLE
    Write-HPFirmwarePasswordFile -password 'mysecret' -outfile mysecret.bin

.NOTES
  - Use single quotes around the password to prevent PowerShell from interpreting special characters in the string.


#>
function Write-HPFirmwarePasswordFile
{
  [CmdletBinding(HelpUri = "https://developers.hp.com/hp-client-management/doc/Write-HPFirmwarePasswordFile")]
  param(
    [Parameter(Mandatory = $true,Position = 0)] [string]$Password,
    [Parameter(Mandatory = $false,Position = 1)] [System.IO.FileInfo]$Outfile = "password.bin"
  )
  Write-Verbose "Creating password file $outfile..."
  [bios_credential_t]$cred = New-Object bios_credential_t
  $cred.authentication = [authentication_t]::auth_t_password;
  $c = New-Object authentication_data_t
  $c.Password = $password
  $c.password_size = $password.Length
  $cred.Data = $c

  $outFile = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($outFile)
  Write-Verbose ("Writing password to file $outfile")
  try {
    switch (Test-OSBitness) {
      32 { $result = [DfmNativeBios]::encrypt_password_to_file32([ref]$cred,$outFile) }
      64 { $result = [DfmNativeBios]::encrypt_password_to_file64([ref]$cred,$outFile) }
    }
    Test-HPPrivateCustomResult -result $result -Category -1 }
  catch [ArgumentException]
  {
    $err = "Failed to process file with path $($_)"
    Write-Verbose $err
    throw $err
  }
  catch [System.Management.Automation.MethodInvocationException]
  {
    displayInvocationException ($_.Exception)
  }
  Write-Verbose "Ok."
}

function createTemporaryDirectory {
  $parent = [System.IO.Path]::GetTempPath()
  [string]$name = [System.Guid]::NewGuid()
  New-Item -ItemType Directory -Path (Join-Path $parent $name)
}




<#
.SYNOPSIS
  This is a private command for internal use only. Retrieves the EFI partition path.

.DESCRIPTION
  This is a private command for internal use only. This command retrieves the path of the EFI partition.

.PARAMETER FixedOnly
  If specified, this command ignores removable drives during search. 

.EXAMPLE
  Get-EFIPartitionPath

.NOTES
  - This command requires elevated privileges. 
  - This is a private command for internal use only
#>
function Get-EFIPartitionPath
{
  [CmdletBinding(HelpUri = "https://developers.hp.com/hp-client-management/doc/Get-EFIPartitionPath")]
  param([Parameter(Mandatory = $false,Position = 1)] [switch]$FixedOnly)

  if (-not (Test-IsElevatedAdmin)) {
    throw [System.Security.AccessControl.PrivilegeNotHeldException]"elevated administrator"
  }

  $volumes = Get-Partition  | Select-Object `
     @{ Name = "Path"; Expression = { (Get-Volume -Partition $_).Path } },`
     @{ Name = "Mount"; Expression = {(Get-Volume -Partition $_).DriveType } },`
     @{ Name = "Type"; Expression = { $_.Type } },`
     @{ Name = "Disk"; Expression = { $_.DiskNumber } }

  if ($fixedOnly) { $volumes = $volumes | Where-Object Mount -EQ "Fixed" }
  [array]$efi = $volumes | Where-Object { $_.type -eq "System" }

  if (-not $efi) {
    throw [System.Management.Automation.ItemNotFoundException]"Could not locate EFI partition. "
  }

  # ignore EFI partitions that may be offline
  [array]$efi = $efi | Where-Object { (Get-Disk -Number $_.Disk).OperationalStatus -eq "Online" }

  if (-not $efi) {
    throw [System.Management.Automation.ItemNotFoundException]"Could not locate EFI partition. "
  }

  # try to match the EFI partition to the boot disk, if we find multiple
  if ($efi.Count -gt 1 -and -not (Test-WinPE))
  {
    Write-Verbose "Found multiple ($($efi.Count)) EFI fixed partitions, trying to trim them down."
    [array]$efi = $efi | Where-Object { (Get-Disk -Number $_.Disk).IsBoot -eq $true }
  }


  if ($efi.Count -gt 1) {
    throw [System.Management.Automation.ItemNotFoundException]"Could not locate EFI partition, too many candidates."
  }


  $efi[0].Path
}

<#
.SYNOPSIS
  This is a private command for internal use only

.DESCRIPTION
  This is a private command for internal use only

.EXAMPLE

.NOTES
  - This is a private command for internal use only
#>
function Get-HPPrivateRetailConfiguration
{
  [CmdletBinding()]
  param()
  $configuration = New-Object RetailInformation
  $mi_result = 0
  $cmd = '[DfmNativeRetail]::get_retail_dock_configuration_' + (Test-OSBitness) + '([ref]$configuration, [ref]$mi_result)';
  $result = Invoke-Expression -Command $cmd
  Test-HPPrivateCustomResult -result $result -mi_result $mi_result -Category 0x04
  return $configuration
}


<#
.SYNOPSIS
  This is a private command for internal use only

.DESCRIPTION
  This is a private command for internal use only

.EXAMPLE

.NOTES
  - This is a private command for internal use only
#>
function Set-HPPrivateRetailConfiguration
{
  [CmdletBinding()]
  param(
    [RetailInformation]$configuration
  )
  $cfg = $configuration
  $mi_result = 0
  $cmd = '[DfmNativeRetail]::set_retail_dock_configuration_' + (Test-OSBitness) + '([ref]$cfg, [ref]$mi_result)';
  $result = Invoke-Expression -Command $cmd
  Test-HPPrivateCustomResult -result $result -mi_result $mi_result -Category 0x04
}

# SIG # Begin signature block
# MIIoHQYJKoZIhvcNAQcCoIIoDjCCKAoCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCtyQoW7IN2ozJn
# tcHul2K4y//irhIIBhaw5hctuvIRBKCCDYowggawMIIEmKADAgECAhAIrUCyYNKc
# TJ9ezam9k67ZMA0GCSqGSIb3DQEBDAUAMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQK
# EwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNV
# BAMTGERpZ2lDZXJ0IFRydXN0ZWQgUm9vdCBHNDAeFw0yMTA0MjkwMDAwMDBaFw0z
# NjA0MjgyMzU5NTlaMGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwg
# SW5jLjFBMD8GA1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBDb2RlIFNpZ25pbmcg
# UlNBNDA5NiBTSEEzODQgMjAyMSBDQTEwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAw
# ggIKAoICAQDVtC9C0CiteLdd1TlZG7GIQvUzjOs9gZdwxbvEhSYwn6SOaNhc9es0
# JAfhS0/TeEP0F9ce2vnS1WcaUk8OoVf8iJnBkcyBAz5NcCRks43iCH00fUyAVxJr
# Q5qZ8sU7H/Lvy0daE6ZMswEgJfMQ04uy+wjwiuCdCcBlp/qYgEk1hz1RGeiQIXhF
# LqGfLOEYwhrMxe6TSXBCMo/7xuoc82VokaJNTIIRSFJo3hC9FFdd6BgTZcV/sk+F
# LEikVoQ11vkunKoAFdE3/hoGlMJ8yOobMubKwvSnowMOdKWvObarYBLj6Na59zHh
# 3K3kGKDYwSNHR7OhD26jq22YBoMbt2pnLdK9RBqSEIGPsDsJ18ebMlrC/2pgVItJ
# wZPt4bRc4G/rJvmM1bL5OBDm6s6R9b7T+2+TYTRcvJNFKIM2KmYoX7BzzosmJQay
# g9Rc9hUZTO1i4F4z8ujo7AqnsAMrkbI2eb73rQgedaZlzLvjSFDzd5Ea/ttQokbI
# YViY9XwCFjyDKK05huzUtw1T0PhH5nUwjewwk3YUpltLXXRhTT8SkXbev1jLchAp
# QfDVxW0mdmgRQRNYmtwmKwH0iU1Z23jPgUo+QEdfyYFQc4UQIyFZYIpkVMHMIRro
# OBl8ZhzNeDhFMJlP/2NPTLuqDQhTQXxYPUez+rbsjDIJAsxsPAxWEQIDAQABo4IB
# WTCCAVUwEgYDVR0TAQH/BAgwBgEB/wIBADAdBgNVHQ4EFgQUaDfg67Y7+F8Rhvv+
# YXsIiGX0TkIwHwYDVR0jBBgwFoAU7NfjgtJxXWRM3y5nP+e6mK4cD08wDgYDVR0P
# AQH/BAQDAgGGMBMGA1UdJQQMMAoGCCsGAQUFBwMDMHcGCCsGAQUFBwEBBGswaTAk
# BggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEEGCCsGAQUFBzAC
# hjVodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9v
# dEc0LmNydDBDBgNVHR8EPDA6MDigNqA0hjJodHRwOi8vY3JsMy5kaWdpY2VydC5j
# b20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNybDAcBgNVHSAEFTATMAcGBWeBDAED
# MAgGBmeBDAEEATANBgkqhkiG9w0BAQwFAAOCAgEAOiNEPY0Idu6PvDqZ01bgAhql
# +Eg08yy25nRm95RysQDKr2wwJxMSnpBEn0v9nqN8JtU3vDpdSG2V1T9J9Ce7FoFF
# UP2cvbaF4HZ+N3HLIvdaqpDP9ZNq4+sg0dVQeYiaiorBtr2hSBh+3NiAGhEZGM1h
# mYFW9snjdufE5BtfQ/g+lP92OT2e1JnPSt0o618moZVYSNUa/tcnP/2Q0XaG3Ryw
# YFzzDaju4ImhvTnhOE7abrs2nfvlIVNaw8rpavGiPttDuDPITzgUkpn13c5Ubdld
# AhQfQDN8A+KVssIhdXNSy0bYxDQcoqVLjc1vdjcshT8azibpGL6QB7BDf5WIIIJw
# 8MzK7/0pNVwfiThV9zeKiwmhywvpMRr/LhlcOXHhvpynCgbWJme3kuZOX956rEnP
# LqR0kq3bPKSchh/jwVYbKyP/j7XqiHtwa+aguv06P0WmxOgWkVKLQcBIhEuWTatE
# QOON8BUozu3xGFYHKi8QxAwIZDwzj64ojDzLj4gLDb879M4ee47vtevLt/B3E+bn
# KD+sEq6lLyJsQfmCXBVmzGwOysWGw/YmMwwHS6DTBwJqakAwSEs0qFEgu60bhQji
# WQ1tygVQK+pKHJ6l/aCnHwZ05/LWUpD9r4VIIflXO7ScA+2GRfS0YW6/aOImYIbq
# yK+p/pQd52MbOoZWeE4wggbSMIIEuqADAgECAhAJvPMqSNxAYhV5FFpsbzOhMA0G
# CSqGSIb3DQEBCwUAMGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwg
# SW5jLjFBMD8GA1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBDb2RlIFNpZ25pbmcg
# UlNBNDA5NiBTSEEzODQgMjAyMSBDQTEwHhcNMjQwMjE1MDAwMDAwWhcNMjUwMjE4
# MjM1OTU5WjBaMQswCQYDVQQGEwJVUzETMBEGA1UECBMKQ2FsaWZvcm5pYTESMBAG
# A1UEBxMJUGFsbyBBbHRvMRAwDgYDVQQKEwdIUCBJbmMuMRAwDgYDVQQDEwdIUCBJ
# bmMuMIIBojANBgkqhkiG9w0BAQEFAAOCAY8AMIIBigKCAYEApbF6fMFy6zhGVra3
# SZN418Cp2O8kjihQCU9tqPO9tkzbMyTsgveLJVnXPJNG9kQPMGUNp+wEHcoUzlRc
# YJMEL9fhfzpWPeSIIezGLPCdrkMmS3fdRUwFqEs7z/C6Ui2ZqMaKhKjBJTIWnipe
# rRfzGB7RoLepQcgqeF5s0DBy4oG83dqcRHo3IJRTBg39tHe3mD5uoGHn5n366abX
# vC+k53BVyD8w8XLppFVH5XuNlXMq/Ohf613i7DRb/+u92ZiAPVPXXnlxUE26cuDb
# OfJKN/bXPmvnWcNW3YHVp9ztPTQZhX4yWYXHrAI2Cv6HxUpO6NzhFoRoBTkcYNbA
# 91pf1Vagh/MNcA2BfQYT975/Vlvj9cfEZ/NwZthZuHa3rdrvCKhhjw7YU2QUeaTJ
# 0uaX4g6B9PFNqAASYLach3CDJiLmYEfus/utPh57mk0q27yL25fXo/PaMDXiDNIi
# 7Wuz7A+sPsbtdiY8zvEIRQ+XJXtKAlD4tqG9YzlTO6ZoQX/rAgMBAAGjggIDMIIB
# /zAfBgNVHSMEGDAWgBRoN+Drtjv4XxGG+/5hewiIZfROQjAdBgNVHQ4EFgQURH4F
# u5yEAuElYWUbyGRYkNLLrA8wPgYDVR0gBDcwNTAzBgZngQwBBAEwKTAnBggrBgEF
# BQcCARYbaHR0cDovL3d3dy5kaWdpY2VydC5jb20vQ1BTMA4GA1UdDwEB/wQEAwIH
# gDATBgNVHSUEDDAKBggrBgEFBQcDAzCBtQYDVR0fBIGtMIGqMFOgUaBPhk1odHRw
# Oi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkRzRDb2RlU2lnbmlu
# Z1JTQTQwOTZTSEEzODQyMDIxQ0ExLmNybDBToFGgT4ZNaHR0cDovL2NybDQuZGln
# aWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZEc0Q29kZVNpZ25pbmdSU0E0MDk2U0hB
# Mzg0MjAyMUNBMS5jcmwwgZQGCCsGAQUFBwEBBIGHMIGEMCQGCCsGAQUFBzABhhho
# dHRwOi8vb2NzcC5kaWdpY2VydC5jb20wXAYIKwYBBQUHMAKGUGh0dHA6Ly9jYWNl
# cnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNENvZGVTaWduaW5nUlNB
# NDA5NlNIQTM4NDIwMjFDQTEuY3J0MAkGA1UdEwQCMAAwDQYJKoZIhvcNAQELBQAD
# ggIBAFiCyuI6qmaQodDyMNpp0l7eIXFgJ4JI59o59PleFj4rcyd/+F4iI7u5if8G
# rV5Kn3s3tK9vfJO8SpqtEh7lL4e69z6v3ohcy4uy2hsjKQ/fFcDo9pQYDGmDVjCa
# D5qSVEIBlJHBe5NKEJAgUE0kaMjLzbi2+8DKJlNtvZ+hatuPl9fMnmU+VbQh7JhZ
# yJdz8Ay0tcQ9lC8HAX5Ah/pU+Vtv+c8gMSxjS1aWXoGCa1869IVi2O6qx7MuX12U
# 1eIpB9XxYr7HSebvg2G7Gz6nCh7u+4k7m3hJu9EStUIN2JII5260+E60uDWoHEhx
# tHbdueFQxJrTKnhplOSaaPFCVBDkWG83ZzN9N3z/45w1pBUNBiPJdRQJ58MhBYQe
# Zl90heMBL8QNQk2i0E5gHNT9pJiCR9+mvJkRxEVgUn+16ZpVnI6kzhThV9qBaWVF
# h83X4UWc/nwHKIuu+4x4fmkYc79A3MrsHflZIO8jOy0GC/xBnZTQ8s5b9Tb2UkHk
# w692Ypl7War3W7M37JCAPC/A7M4CwQYjdjG43zs5m36auYVaTvRLKtZVLzcj8oZX
# 4vqhlZ8+jCPXFiuDfoBXiTckTLpv/eHQ6q7Aoda+qARWPPE1U2v5r/lpKVqIx7B4
# PdFZAUf5MtG/Bj7LVXvXjW8ABIJv7L4cI2akn6Es0dmvd6PsMYIZ6TCCGeUCAQEw
# fTBpMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xQTA/BgNV
# BAMTOERpZ2lDZXJ0IFRydXN0ZWQgRzQgQ29kZSBTaWduaW5nIFJTQTQwOTYgU0hB
# Mzg0IDIwMjEgQ0ExAhAJvPMqSNxAYhV5FFpsbzOhMA0GCWCGSAFlAwQCAQUAoHww
# EAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYK
# KwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIJovK+Jg
# 2Zg8rzvvjePoj8EtI1GH2cf16RgT2vkQmSljMA0GCSqGSIb3DQEBAQUABIIBgH1O
# ksgZ5Wcjbdm801SNG0yZbTmgb9/BWO89Q48/rnP8WpuVt73wFSSRIQ7vtTGobeph
# AzLNZC3z8KNSe6FrSD2fzfUkg9FWm/SRplH0e95FKfhcKKR2kq1dbjWhy5l4x3rv
# D23GX9GPGk1ocqILcaFEspwcSqRYH3DIBgbdsg9eNPiHm6uBBnxNxVToc3JVjeCn
# kbwGx+A9GSDqi8HvC3fA9oWvibxtXArv7e3/M4RX3n2UTB3jja9oqUS3FvMRVqBG
# TJqo7bblgx3im8h+NcxXmmDM8BZOGJYYbjcj6jmuJFeDnff9Zaph2i8NoYsqogXc
# PVSognJBETSEuYKrhqvgvWTQ3GZmr7gQlSXQVU+UPkX4iUwR8h2UyBsXZMcEi9gn
# cqUMGXRZkEn4aoc3vy27YJWOhgGTgo94LVToVLcc+UjfGigZJVyskbKU8+tovsiJ
# aune5b9YNo1PaMDYG5z2VUffxMQiytNv0i+79j6T2nG6Bhaln0y+raa5SAtyXqGC
# Fz8wghc7BgorBgEEAYI3AwMBMYIXKzCCFycGCSqGSIb3DQEHAqCCFxgwghcUAgED
# MQ8wDQYJYIZIAWUDBAIBBQAwdwYLKoZIhvcNAQkQAQSgaARmMGQCAQEGCWCGSAGG
# /WwHATAxMA0GCWCGSAFlAwQCAQUABCDHmbjNjdcDtkLZRISPUJS9iVStU9FljRl7
# Tspav/6B3AIQey+n5aPr63yv0CSoO5VdzBgPMjAyNDAyMjgxOTU1NDZaoIITCTCC
# BsIwggSqoAMCAQICEAVEr/OUnQg5pr/bP1/lYRYwDQYJKoZIhvcNAQELBQAwYzEL
# MAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQDEzJE
# aWdpQ2VydCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFtcGluZyBD
# QTAeFw0yMzA3MTQwMDAwMDBaFw0zNDEwMTMyMzU5NTlaMEgxCzAJBgNVBAYTAlVT
# MRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjEgMB4GA1UEAxMXRGlnaUNlcnQgVGlt
# ZXN0YW1wIDIwMjMwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQCjU0WH
# HYOOW6w+VLMj4M+f1+XS512hDgncL0ijl3o7Kpxn3GIVWMGpkxGnzaqyat0QKYoe
# YmNp01icNXG/OpfrlFCPHCDqx5o7L5Zm42nnaf5bw9YrIBzBl5S0pVCB8s/LB6Yw
# aMqDQtr8fwkklKSCGtpqutg7yl3eGRiF+0XqDWFsnf5xXsQGmjzwxS55DxtmUuPI
# 1j5f2kPThPXQx/ZILV5FdZZ1/t0QoRuDwbjmUpW1R9d4KTlr4HhZl+NEK0rVlc7v
# CBfqgmRN/yPjyobutKQhZHDr1eWg2mOzLukF7qr2JPUdvJscsrdf3/Dudn0xmWVH
# VZ1KJC+sK5e+n+T9e3M+Mu5SNPvUu+vUoCw0m+PebmQZBzcBkQ8ctVHNqkxmg4ho
# Yru8QRt4GW3k2Q/gWEH72LEs4VGvtK0VBhTqYggT02kefGRNnQ/fztFejKqrUBXJ
# s8q818Q7aESjpTtC/XN97t0K/3k0EH6mXApYTAA+hWl1x4Nk1nXNjxJ2VqUk+tfE
# ayG66B80mC866msBsPf7Kobse1I4qZgJoXGybHGvPrhvltXhEBP+YUcKjP7wtsfV
# x95sJPC/QoLKoHE9nJKTBLRpcCcNT7e1NtHJXwikcKPsCvERLmTgyyIryvEoEyFJ
# UX4GZtM7vvrrkTjYUQfKlLfiUKHzOtOKg8tAewIDAQABo4IBizCCAYcwDgYDVR0P
# AQH/BAQDAgeAMAwGA1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgw
# IAYDVR0gBBkwFzAIBgZngQwBBAIwCwYJYIZIAYb9bAcBMB8GA1UdIwQYMBaAFLoW
# 2W1NhS9zKXaaL3WMaiCPnshvMB0GA1UdDgQWBBSltu8T5+/N0GSh1VapZTGj3tXj
# STBaBgNVHR8EUzBRME+gTaBLhklodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGln
# aUNlcnRUcnVzdGVkRzRSU0E0MDk2U0hBMjU2VGltZVN0YW1waW5nQ0EuY3JsMIGQ
# BggrBgEFBQcBAQSBgzCBgDAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNl
# cnQuY29tMFgGCCsGAQUFBzAChkxodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20v
# RGlnaUNlcnRUcnVzdGVkRzRSU0E0MDk2U0hBMjU2VGltZVN0YW1waW5nQ0EuY3J0
# MA0GCSqGSIb3DQEBCwUAA4ICAQCBGtbeoKm1mBe8cI1PijxonNgl/8ss5M3qXSKS
# 7IwiAqm4z4Co2efjxe0mgopxLxjdTrbebNfhYJwr7e09SI64a7p8Xb3CYTdoSXej
# 65CqEtcnhfOOHpLawkA4n13IoC4leCWdKgV6hCmYtld5j9smViuw86e9NwzYmHZP
# VrlSwradOKmB521BXIxp0bkrxMZ7z5z6eOKTGnaiaXXTUOREEr4gDZ6pRND45Ul3
# CFohxbTPmJUaVLq5vMFpGbrPFvKDNzRusEEm3d5al08zjdSNd311RaGlWCZqA0Xe
# 2VC1UIyvVr1MxeFGxSjTredDAHDezJieGYkD6tSRN+9NUvPJYCHEVkft2hFLjDLD
# iOZY4rbbPvlfsELWj+MXkdGqwFXjhr+sJyxB0JozSqg21Llyln6XeThIX8rC3D0y
# 33XWNmdaifj2p8flTzU8AL2+nCpseQHc2kTmOt44OwdeOVj0fHMxVaCAEcsUDH6u
# vP6k63llqmjWIso765qCNVcoFstp8jKastLYOrixRoZruhf9xHdsFWyuq69zOuhJ
# RrfVf8y2OMDY7Bz1tqG4QyzfTkx9HmhwwHcK1ALgXGC7KP845VJa1qwXIiNO9OzT
# F/tQa/8Hdx9xl0RBybhG02wyfFgvZ0dl5Rtztpn5aywGRu9BHvDwX+Db2a2QgESv
# gBBBijCCBq4wggSWoAMCAQICEAc2N7ckVHzYR6z9KGYqXlswDQYJKoZIhvcNAQEL
# BQAwYjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UE
# CxMQd3d3LmRpZ2ljZXJ0LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQgVHJ1c3RlZCBS
# b290IEc0MB4XDTIyMDMyMzAwMDAwMFoXDTM3MDMyMjIzNTk1OVowYzELMAkGA1UE
# BhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQDEzJEaWdpQ2Vy
# dCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFtcGluZyBDQTCCAiIw
# DQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAMaGNQZJs8E9cklRVcclA8TykTep
# l1Gh1tKD0Z5Mom2gsMyD+Vr2EaFEFUJfpIjzaPp985yJC3+dH54PMx9QEwsmc5Zt
# +FeoAn39Q7SE2hHxc7Gz7iuAhIoiGN/r2j3EF3+rGSs+QtxnjupRPfDWVtTnKC3r
# 07G1decfBmWNlCnT2exp39mQh0YAe9tEQYncfGpXevA3eZ9drMvohGS0UvJ2R/dh
# gxndX7RUCyFobjchu0CsX7LeSn3O9TkSZ+8OpWNs5KbFHc02DVzV5huowWR0QKfA
# csW6Th+xtVhNef7Xj3OTrCw54qVI1vCwMROpVymWJy71h6aPTnYVVSZwmCZ/oBpH
# IEPjQ2OAe3VuJyWQmDo4EbP29p7mO1vsgd4iFNmCKseSv6De4z6ic/rnH1pslPJS
# lRErWHRAKKtzQ87fSqEcazjFKfPKqpZzQmiftkaznTqj1QPgv/CiPMpC3BhIfxQ0
# z9JMq++bPf4OuGQq+nUoJEHtQr8FnGZJUlD0UfM2SU2LINIsVzV5K6jzRWC8I41Y
# 99xh3pP+OcD5sjClTNfpmEpYPtMDiP6zj9NeS3YSUZPJjAw7W4oiqMEmCPkUEBID
# fV8ju2TjY+Cm4T72wnSyPx4JduyrXUZ14mCjWAkBKAAOhFTuzuldyF4wEr1GnrXT
# drnSDmuZDNIztM2xAgMBAAGjggFdMIIBWTASBgNVHRMBAf8ECDAGAQH/AgEAMB0G
# A1UdDgQWBBS6FtltTYUvcyl2mi91jGogj57IbzAfBgNVHSMEGDAWgBTs1+OC0nFd
# ZEzfLmc/57qYrhwPTzAOBgNVHQ8BAf8EBAMCAYYwEwYDVR0lBAwwCgYIKwYBBQUH
# AwgwdwYIKwYBBQUHAQEEazBpMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdp
# Y2VydC5jb20wQQYIKwYBBQUHMAKGNWh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNv
# bS9EaWdpQ2VydFRydXN0ZWRSb290RzQuY3J0MEMGA1UdHwQ8MDowOKA2oDSGMmh0
# dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRSb290RzQuY3Js
# MCAGA1UdIAQZMBcwCAYGZ4EMAQQCMAsGCWCGSAGG/WwHATANBgkqhkiG9w0BAQsF
# AAOCAgEAfVmOwJO2b5ipRCIBfmbW2CFC4bAYLhBNE88wU86/GPvHUF3iSyn7cIoN
# qilp/GnBzx0H6T5gyNgL5Vxb122H+oQgJTQxZ822EpZvxFBMYh0MCIKoFr2pVs8V
# c40BIiXOlWk/R3f7cnQU1/+rT4osequFzUNf7WC2qk+RZp4snuCKrOX9jLxkJods
# kr2dfNBwCnzvqLx1T7pa96kQsl3p/yhUifDVinF2ZdrM8HKjI/rAJ4JErpknG6sk
# HibBt94q6/aesXmZgaNWhqsKRcnfxI2g55j7+6adcq/Ex8HBanHZxhOACcS2n82H
# hyS7T6NJuXdmkfFynOlLAlKnN36TU6w7HQhJD5TNOXrd/yVjmScsPT9rp/Fmw0HN
# T7ZAmyEhQNC3EyTN3B14OuSereU0cZLXJmvkOHOrpgFPvT87eK1MrfvElXvtCl8z
# OYdBeHo46Zzh3SP9HSjTx/no8Zhf+yvYfvJGnXUsHicsJttvFXseGYs2uJPU5vIX
# mVnKcPA3v5gA3yAWTyf7YGcWoWa63VXAOimGsJigK+2VQbc61RWYMbRiCQ8KvYHZ
# E/6/pNHzV9m8BPqC3jLfBInwAM1dwvnQI38AC+R2AibZ8GV2QqYphwlHK+Z/GqSF
# D/yYlvZVVCsfgPrA8g4r5db7qS9EFUrnEw4d2zc4GqEr9u3WfPwwggWNMIIEdaAD
# AgECAhAOmxiO+dAt5+/bUOIIQBhaMA0GCSqGSIb3DQEBDAUAMGUxCzAJBgNVBAYT
# AlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2Vy
# dC5jb20xJDAiBgNVBAMTG0RpZ2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBDQTAeFw0y
# MjA4MDEwMDAwMDBaFw0zMTExMDkyMzU5NTlaMGIxCzAJBgNVBAYTAlVTMRUwEwYD
# VQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAf
# BgNVBAMTGERpZ2lDZXJ0IFRydXN0ZWQgUm9vdCBHNDCCAiIwDQYJKoZIhvcNAQEB
# BQADggIPADCCAgoCggIBAL/mkHNo3rvkXUo8MCIwaTPswqclLskhPfKK2FnC4Smn
# PVirdprNrnsbhA3EMB/zG6Q4FutWxpdtHauyefLKEdLkX9YFPFIPUh/GnhWlfr6f
# qVcWWVVyr2iTcMKyunWZanMylNEQRBAu34LzB4TmdDttceItDBvuINXJIB1jKS3O
# 7F5OyJP4IWGbNOsFxl7sWxq868nPzaw0QF+xembud8hIqGZXV59UWI4MK7dPpzDZ
# Vu7Ke13jrclPXuU15zHL2pNe3I6PgNq2kZhAkHnDeMe2scS1ahg4AxCN2NQ3pC4F
# fYj1gj4QkXCrVYJBMtfbBHMqbpEBfCFM1LyuGwN1XXhm2ToxRJozQL8I11pJpMLm
# qaBn3aQnvKFPObURWBf3JFxGj2T3wWmIdph2PVldQnaHiZdpekjw4KISG2aadMre
# Sx7nDmOu5tTvkpI6nj3cAORFJYm2mkQZK37AlLTSYW3rM9nF30sEAMx9HJXDj/ch
# srIRt7t/8tWMcCxBYKqxYxhElRp2Yn72gLD76GSmM9GJB+G9t+ZDpBi4pncB4Q+U
# DCEdslQpJYls5Q5SUUd0viastkF13nqsX40/ybzTQRESW+UQUOsxxcpyFiIJ33xM
# dT9j7CFfxCBRa2+xq4aLT8LWRV+dIPyhHsXAj6KxfgommfXkaS+YHS312amyHeUb
# AgMBAAGjggE6MIIBNjAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBTs1+OC0nFd
# ZEzfLmc/57qYrhwPTzAfBgNVHSMEGDAWgBRF66Kv9JLLgjEtUYunpyGd823IDzAO
# BgNVHQ8BAf8EBAMCAYYweQYIKwYBBQUHAQEEbTBrMCQGCCsGAQUFBzABhhhodHRw
# Oi8vb2NzcC5kaWdpY2VydC5jb20wQwYIKwYBBQUHMAKGN2h0dHA6Ly9jYWNlcnRz
# LmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcnQwRQYDVR0f
# BD4wPDA6oDigNoY0aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNz
# dXJlZElEUm9vdENBLmNybDARBgNVHSAECjAIMAYGBFUdIAAwDQYJKoZIhvcNAQEM
# BQADggEBAHCgv0NcVec4X6CjdBs9thbX979XB72arKGHLOyFXqkauyL4hxppVCLt
# pIh3bb0aFPQTSnovLbc47/T/gLn4offyct4kvFIDyE7QKt76LVbP+fT3rDB6mouy
# XtTP0UNEm0Mh65ZyoUi0mcudT6cGAxN3J0TU53/oWajwvy8LpunyNDzs9wPHh6jS
# TEAZNUZqaVSwuKFWjuyk1T3osdz9HNj0d1pcVIxv76FQPfx2CWiEn2/K2yCNNWAc
# AgPLILCsWKAOQGPFmCLBsln1VWvPJ6tsds5vIy30fnFqI2si/xK4VC0nftg62fC2
# h5b9W9FcrBjDTZ9ztwGpn1eqXijiuZQxggN2MIIDcgIBATB3MGMxCzAJBgNVBAYT
# AlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkGA1UEAxMyRGlnaUNlcnQg
# VHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBUaW1lU3RhbXBpbmcgQ0ECEAVEr/OU
# nQg5pr/bP1/lYRYwDQYJYIZIAWUDBAIBBQCggdEwGgYJKoZIhvcNAQkDMQ0GCyqG
# SIb3DQEJEAEEMBwGCSqGSIb3DQEJBTEPFw0yNDAyMjgxOTU1NDZaMCsGCyqGSIb3
# DQEJEAIMMRwwGjAYMBYEFGbwKzLCwskPgl3OqorJxk8ZnM9AMC8GCSqGSIb3DQEJ
# BDEiBCC+N5QJmEaRbDActA4OkJAKyOWGMAC3EltJnU2fyuvy2DA3BgsqhkiG9w0B
# CRACLzEoMCYwJDAiBCDS9uRt7XQizNHUQFdoQTZvgoraVZquMxavTRqa1Ax4KDAN
# BgkqhkiG9w0BAQEFAASCAgB8si1sCNQnqJlCjVFFnyONiSuyQH5mE3lYYyuknSSW
# q93yRxk/9lDlb6V4/6T8Bj3YLJwR6CLhWeLCDfk92bbWFNTF/fgiIuApFsSyqJNV
# 2DFV19Lm6nIJTnOGvEyepPHUHi0B8aaBt43SaOy1DlNZRGWgRANmMQTBaAwuaEEP
# ckS/8RGm/Oto2Bn61sXxsFi0Xgbyeisje4nNQ9ssGliiSvJkZHUU5HqgSLX8wvTa
# W/ZJoiLaGJxUutKw/GyRNWWjvticcbfOkKGs14RpCnsMwajDXfR/ZZTM9raZK2HW
# rP0NFIrVk2TuEbx03lZ9/sybl4lqVsNqudn71wkVa7uGNBdcxctr7hEsENJ37K2P
# 7MAh/WID2jzGr3oruhh0La9OksceOLT8APxZqIlOOBdMUHdeLALcBcwpbwZSAUhF
# MQvGJo9aqRUtTCpMoFi/FvHeSDMi2+DKJoomCA/YGnoxfQ0ExCjYY9fz0/MdqVvC
# e/p5R5Y/VcFi4FmC3t4A46UZA3ph8THEV5onofVzZBDACfKYBH3Rq/JbamOPj2uv
# qgTHHSfZmoMb8bXwz3R5vksrXfl44axhparRMJfbiPBssvZlMpsWFInhDk34XxTA
# pxilC7ry0DtbkSVmIlrDBG9KCY90fDRytd6aD4r+8SHflPr30WZdrGjmZDM+Itko
# 3Q==
# SIG # End signature block
