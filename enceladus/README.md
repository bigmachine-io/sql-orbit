 
# Enceladus Analysis Preparation

I'm importing the Cassini mission plan into Postgres into the `cassini` schema, setting everything as `text` so I can evaluate the data and query it easily.

## Problems

 - There are 2 different dates. One is an unusual UTC timestamp, the other is a more common date format
 - The "date" column contains 8 rows of an invalid date: "29-Feb-14", which is an invalid leap year. This also exists in the CSV and is not the result of the import process. **Ignoring this field**.

## Isolation and Transformation for Flybys

I created the `enceladus/transform.sql` script to pull the Enceladus mission plan data from the `csvs.master_plan` data. I added the following types and constraints:

 - created an `enceladus` schema and a `plans` table
 - set `start_time_utc` to a `timestamp` and renamed it `start`
 - set `title` to `not null` and only pulled in plan data with non null titles
  
The transform stuff worked but it turned out that the dates that are in the master_plan CSV don't seem to align with what's been published on the NASA website. The master_plan CSV is from JPL, the flyby dates are from NASA so... I think I'm going to trust NASA. 

To that end, I created a `flybys.sql` file with hard-coded dates and checked 3 times for accuracy. This will serve as the flyby authority.

## Import and Transformation of the INMS Data

I updated the import script and completely removed the import of the `master_plan` data as I won't be using it. I pulled in all of the INMS information and then transformed it for use with the `enceladus` schema.

I also added the chemical data from the chem_data.csv file to the `chemistry` table.

### Problems

I found a few problems during the transformation process:

 - the `source` field was reported by the manifest to have 4 possible values (osi, csn, osnb and osnt). It turns out this is not accurate - osnt is not in the data but "esm" is. I can't tell if this is a substitution value and have decided to wait to see if this is a problem.
 - there are header rows and extra rows for unit of measure specification repeated throughout the data as the result of concatenating 500+ CSVs. I decided to strip those files during import using a delete statement where the sclk field is `sclk` (indicating a header row) or if that field was `null`, indicating a unit of measure row.
 - the mass_per_charge field is reported in the manifest to have a valid maximum of 99.0, whereas the data has a max value of 255.875. I'm trusting the data with this and altered the table constraint to allow for 255.875
