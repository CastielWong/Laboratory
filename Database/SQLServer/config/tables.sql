
CREATE TABLE [dummy].[source] (
    [id] [INT]  NOT NULL
    , [date] [DATE] NOT NULL
    , [name] [VARCHAR](100) COLLATE Latin1_General_CS_AS    NOT NULL
    , [check] [BIT] NOT NULL
) ON [PRIMARY]
WITH (DATA_COMPRESSION = PAGE)
GO

ALTER TABLE [dummy].[source]
    ADD CONSTRAINT [PK__dummy_source] PRIMARY KEY NONCLUSTERED ([id])
    WITH (DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO

CREATE CLUSTERED INDEX [CIX__dummy_source]
    ON [dummy].[source] ([date])
    WITH (DATA_COMPRESSION = PAGE) ON [ps_year] ([date])
GO
