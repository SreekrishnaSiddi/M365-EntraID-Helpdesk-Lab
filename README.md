# Microsoft 365 & Entra ID Help Desk Lab

A hands-on lab simulating IT support for **Northstar Information Systems (NIS)**, a fictional company, in a real Microsoft 365 Business Premium tenant. I worked through 16 realistic help desk and security tickets covering identity, email, file access, Conditional Access, Intune device management, and PowerShell automation.

> All users, data, and the company itself are fictional. Built for learning and portfolio purposes.

---

## Environment

| Component | Details |
|---|---|
| Tenant | Microsoft 365 Business Premium (trial), Entra ID P1 |
| Admin portals | Microsoft 365 admin center, Entra admin center, Exchange admin center, SharePoint admin center, Intune admin center |
| Test device | Windows 11 Pro VM (VirtualBox), Entra joined and Intune enrolled (`NIS-LT-001`) |
| Automation | PowerShell 5.1 with the Microsoft Graph SDK |
| Accounts | Daily admin, break-glass emergency admin, 6 staff users, 5 script-created new hires |

---

## Tickets Resolved

### Phase 1 – Users, Groups & Licensing
| # | Ticket | What I did |
|---|---|---|
| 1001 | New hire setup | Created users with department/title data, security groups (`SG-` naming convention), a dynamic group (`DYN-Sales`, rule `user.department -eq "Sales"`), a Microsoft 365 group with a Team, and a distribution list. Licensed users through **group-based licensing** (`SG-All-Licensed`). Found and fixed a user left out of the licensing group. |

### Phase 2 – Everyday Help Desk
| # | Ticket | What I did |
|---|---|---|
| 1002 | Self-service password reset | Enabled SSPR for licensed users, required registration, tested an end-to-end reset. Encountered Entra **Password Protection** rejecting a common password. |
| 1003 | Admin password reset | Reset with a temporary password and forced change at sign-in; troubleshot a failed first sign-in. |
| 1004 | MFA reset (lost phone) | Removed the old Authenticator method, required re-registration, **revoked sessions**. |
| 1005 | "My account is locked" | Used **sign-in logs** to find error **50057** (account disabled), not a lockout as the user believed. Unblocked the account. |
| 1006 | Offboarding | Blocked sign-in, reset password, revoked sessions, converted mailbox to shared, delegated manager access, removed licensing group membership. |

### Phase 3 – Exchange, Teams & SharePoint
| # | Ticket | What I did |
|---|---|---|
| 1007 | Shared mailbox | Created `support@` with Full Access and Send As for two users. |
| 1008 | "Missing" email | Ran a **message trace** in Exchange admin center to confirm delivery. |
| 1009 | File access request | Discovered a Sales user could **edit** Finance's budget (oversharing). Fixed site privacy and sharing links, then granted **view-only access to one file** with the data owner's approval (least privilege). Rolled back unauthorized edits with **version history**. |
| 1010 | Deleted file | Restored from the SharePoint recycle bin (first/second-stage, 93-day retention). |

### Phase 4 – Conditional Access & Security
| # | Ticket | What I did |
|---|---|---|
| 1011 | Enforce MFA | Disabled Security defaults, created `CA001` requiring MFA for all users with a **break-glass exclusion**. Validated in **Report-only** first, then enabled. Traced an unexpected prompt to the SSPR registration requirement. |
| 1012 | Block legacy authentication | Created `CA002`. **Report-only testing caught a misconfiguration** that would have blocked every user; fixed the client-app condition before enforcing. |
| 1013 | Traveling user | Created `CA003` (block sign-ins outside the US) and a **temporary, documented exception group** for one traveler, verified with the **What If** tool. |
| 1013c | Tenant lockout | A missing location exclusion in `CA003` blocked all admins (error **53003**). **Recovered with the break-glass account**, found the cause in sign-in logs, fixed the policy, and validated both allow and block cases. |

### Phase 5 – Intune Device Management
| # | Ticket | What I did |
|---|---|---|
| 1014 | New laptop | Configured automatic MDM enrollment, set up a Windows 11 Pro device via "Set up for work or school" (Entra join + Intune enrollment + Windows Hello for Business), renamed it from Intune, corrected ownership from Personal to Corporate. Handled a **BitLocker recovery** using the key escrowed in Entra ID. |
| 1015 | Non-compliant device | Built a compliance policy (firewall, Defender, minimum OS). Used the **per-setting compliance report** to find the failing requirement and corrected the policy. |

### Phase 6 – PowerShell Automation
| # | Ticket | What I did |
|---|---|---|
| 1016 | Bulk onboarding | Wrote [`New-NISHires.ps1`](New-NISHires.ps1), which reads an HR CSV, creates users with random temporary passwords, sets profile data, and adds them to the licensing group. Includes duplicate checks, error handling, and a results log. |

---

## Key Lessons

- **Test before enforcing.** Report-only mode caught a Conditional Access policy that would have locked out every user.
- **Always keep a break-glass account.** It was the only way back in after a policy blocked all admins.
- **Check both sides of a policy.** Validate what should be allowed, not just what should be blocked.
- **Logs over assumptions.** "My account is locked" turned out to be a disabled account (50057), and an unexpected MFA prompt came from a different setting than expected.
- **Least privilege for data.** The data owner decides access; the help desk grants the minimum needed.
- **Microsoft enforces MFA on admin portals** regardless of Conditional Access exclusions.

---

## Skills Demonstrated

Microsoft Entra ID · Microsoft 365 administration · Exchange Online · SharePoint Online · Microsoft Teams · Conditional Access · MFA / SSPR · Microsoft Intune · BitLocker · Windows 11 · PowerShell (Microsoft Graph) · Sign-in log analysis · Ticket documentation
