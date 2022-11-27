drop table if exists `CartLine`;
drop table if exists `OrderLine`;
drop table if exists `Product`;
drop table if exists `Cart`;
drop table if exists `Product`;
drop table if exists `ProductCategory`;
drop table if exists `Pallet`;
drop table if exists `BoxDesign`;
drop table if exists `TransportData`;
drop table if exists `Order`;
drop table if exists `Customer`;

CREATE TABLE `Customer` (
  `Id` varchar(15),
  `FirtName` Varchar(30),
  `LastName` Varchar(30),
  PRIMARY KEY (`Id`)
);

CREATE TABLE `Order` (
  `Id` varchar(15),
  `CostumerID` varchar(15),
  `Status` Varchar(10),
  `City` Varchar(30),
  `County` Varchar(30),
  `PostalCode` Varchar(10),
  `Street` Varchar(30),
  `Number` Varchar(10),
  PRIMARY KEY (`Id`),
  FOREIGN KEY (`CostumerID`) REFERENCES `Customer`(`Id`)
);

CREATE TABLE `TransportData` (
  `CreatedAt` DATETIME,
  `EditedAt` DATETIME,
  `Id` varchar(15),
  `OrderId` varchar(15),
  `Longitude` Float(10,6),
  `Latitude` Float(10,6),
  PRIMARY KEY (`Id`),
  FOREIGN KEY (`OrderId`) REFERENCES `Order`(`Id`)
);

CREATE TABLE `BoxDesign` (
  `CreatedAt` DATETIME,
  `EditedAt` DATETIME,
  `Id` Varchar(15),
  `CostumerID` Varchar(15),
  `Width` Float(8,2),
  `Heigth` Float(8,2),
  `Depth` Float(8,2),
  `Name` Varchar(20),
  `Price` Decimal(6,2),
  PRIMARY KEY (`Id`),
  FOREIGN KEY (`CostumerID`) REFERENCES `Customer`(`Id`)
);

CREATE TABLE `Pallet` (
  `CreatedAt` DATETIME,
  `EditedAt` DATETIME,
  `Id` Varchar(15),
  `Width` Float(8,2),
  `Heigth` Float(8,2),
  `Depth` Float(8,2),
  `Price` Decimal(6,2),
  PRIMARY KEY (`Id`)
);

CREATE TABLE `ProductCategory` (
  `Id` varchar(15),
  `Name` Varchar(20),
  PRIMARY KEY (`Id`)
);


CREATE TABLE `Product` (
  `Id` varchar(15),
  `CategoryID` Varchar(30),
  `ProductName` Varchar(20),
  `Cost` Decimal(10,2),
  `Width` float,
  `Heigth` float,
  `Depth` float,
  PRIMARY KEY (`Id`),
  FOREIGN KEY (`CategoryID`) REFERENCES `ProductCategory`(`Id`)
);


CREATE TABLE `Cart` (
  `CreatedAt` DATETIME,
  `EditedAt` DATETIME,
  `Id` varchar(15),
  `CostumerID` varchar(15),
  PRIMARY KEY (`Id`),
  FOREIGN KEY (`CostumerID`) REFERENCES `Customer`(`Id`)
);

CREATE TABLE `OrderLine` (
  `CreatedAt` DATETIME,
  `EditedAt` DATETIME,
  `Id` varchar(15),
  `BoxID` Varchar(15),
  `ProductID` varchar(15),
  `OrderId` Varchar(30),
  `Price` Decimal(10,2),
  `ProductQuantity` integer,
  `PalletID` Varchar(15),
  `PalletQuantity` Integer,
  PRIMARY KEY (`Id`),
  FOREIGN KEY (`ProductID`) REFERENCES `Product`(`Id`),
  FOREIGN KEY (`OrderId`) REFERENCES `Order`(`Id`)
);

CREATE TABLE `CartLine` (
  `CreatedAt` DATETIME,
  `EditedAt` DATETIME,
  `Id` varchar(15),
  `ProductID` varchar(15),
  `Quantity` integer,
  `CartId` varchar(15),
  `Price` Decimal(10,2),
  PRIMARY KEY (`Id`),
  FOREIGN KEY (`CartId`) REFERENCES `Cart`(`Id`),
  FOREIGN KEY (`ProductID`) REFERENCES `Product`(`Id`)
);