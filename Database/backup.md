
This markdown is to describe the rough idea in database backup.


- [Acronym](#acronym)
- [Strategy](#strategy)
- [Comparison ](#comparison)
- [Reference](#reference)
 

## Acronym
- RTO: Recovery Time Objective
- RPO: Recovery Point Objective
- ACID: Atomicity, Consistency, Isolation, Durability

## Strategy
Define backup strategy:
- where to store the backup
- what kind of backup to do
- will there a need to be able to recover at a particular point in time?
- how often
- how long to keep the backup
 
Database backup strategy:
- Full Backup
- Full Backup + Transaction Log Backup
- Full Backup + Differential Backups + Transaction Log Backups
 
Failure Classification:
- Type 1: Transaction Failure
  - Logical Errors
  - Internal State Errors
- TYpe 2: System Failure
  - Software Failure
  - Hardware Failure
- Type 3: Storage Media Failure
 
Terminology:
- Steal: Whether the DBMS allows an uncommitted txn to overwrite the most recent committed value of an object in non-volatile storage
- Force: Whether the DBMS requires that all updates made by a txn are reflected on non-volatile storage before the tx can commit
- Non-Steal + Force: cause too much overhead during transactions as page copied is needed at every operation
- Steal + Non-Force

Physical Logging - Physiological Logging
 
Recovery algorithms have two parts:
- Actions during normal txn processing to ensure that the DBMS can recover from a failure
- Actions after a failure to recover the database to a state that ensures atomicity, consistency, and durability
 
Checkpoint:
1. output onto stable storage all log records currently residing in main memory
2. output to the disk all modified blocks
3. write a <CHECKPOINT> entry to the log and flush to stable storage
 
ARIES - Recovery Phases:
1. Analysis: Read WAL from last MasterRecord to identify dirty pages in the buffer pool and active txns at the time of crash
2. Redo: Repeat all actions starting from appropriate point in the log (even txns that will abort)
3. Undo: Reverse the actions of txns that did not commit before the crash
 
 
How to develop a good database backup and recovery strategy:
1. never back up databases to local disk
2. after you back up the databases to a file share, back up the share to tape
3. justify the cost of the network share by lower licensing costs and simpler backups
4. do regular fire drill rebuilds and restores
5. keep management informed on restore time estimates
6. trust no one
7. have solid backup and disaster recovery plans in place before you move to the cloud
 
 

## Comparison 
| Model | Description | Pros | Cons |
| --- | --- | --- | --- |
| Full | Backs up the entire database, including part of the transaction log for recovery. Represents a consistent image of the database at the time when the backup is finished. | simple, easy | Large in size, time-consuming, and require scheduling |
| Partial | Backup primary and all read/write filegroups with a part of the transaction log for recovery. | small backup size | Read-only filegroups not backed up. |
| File/Filegroup | Backs up specified files(s) or filegroup(s) with a part of the transaction log for file recovery. | Flexibility in scheduling. | Complex, files must be online. |
| Differential | Works in conjunction with full backups to identify changes that have been made since the last Full Backup and stores modified data. | | |
| Copy Only | All database backup, independent of the backup sequence. Great for one-off backups intended for restoring to non-production. | | |
| Transaction Log | Backs up a portion of the transaction log for recovery, then frees up this space in the transaction log for other use. | | |

## Reference
- Database Logging (CMU Intro to Database Systems / Fall 2021): https://www.youtube.com/watch?v=mD5znxu4Vq4
- DolphinDB 数据备份恢复教程: https://gitee.com/dolphindb/Tutorials_CN/blob/master/restore-backup.md
- Designing a Successful Database Backup Strategy: https://www.fortifieddata.com/designing-a-successful-database-backup-strategy/
