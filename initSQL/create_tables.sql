-- create table addresses
-- (
--     id         integer
--         constraint addresses_pk
--             primary key,
--     street     varchar,
--     number     varchar,
--     city       varchar,
--     post_code  varchar,
--     vaild_from timestamp default CURRENT_TIMESTAMP not null,
--     vaild_to   timestamp
-- );

create table agencies
(
    id            integer                             not null
        constraint agencies_pk
            primary key,
    name          varchar                             not null,
    street        varchar,
    street_number varchar,
    city_code     varchar,
    city          varchar,
    vaild_from    timestamp default CURRENT_TIMESTAMP not null,
    vaild_to      varchar
);

create table agents
(
    id            integer                             not null
        constraint agents_pk
            primary key,
    first_name    integer                             not null,
    last_name     integer                             not null,
    agency        integer
        constraint agent_agencies_null_fk
            references agencies,
    commission    integer                             not null,
    isExternal    boolean,
        street varchar,
    street_number varchar,
    city_code     varchar,
    city          varchar,
    vaild_from    timestamp default CURRENT_TIMESTAMP not null,
    vaild_to      timestamp
);

create table customer
(
    id            integer                             not null
        constraint customer_pk
            primary key,
    first_name    varchar                             not null,
    last_name     varchar                             not null,
    street        varchar,
    street_number varchar,
    city_code     varchar,
    city          varchar,
    profession    varchar,
    isBusiness    boolean,
    vaild_from    timestamp default CURRENT_TIMESTAMP not null,
    vaild_to      timestamp
);

create table branches
(
    name       varchar                             not null,
    region     varchar                             not null,
    id         integer
        constraint id
            primary key,
    agent_id   integer
        constraint agent_id
            references agents (id),
    vaild_from timestamp default CURRENT_TIMESTAMP not null,
    vaild_to   timestamp
);

create table product_groups
(
    id         integer                             not null
        constraint product_groups_pk
            primary key,
    name       varchar                             not null,
    branch_id  integer
        constraint products_branch__fk
            references branches (id),
    vaild_from timestamp default CURRENT_TIMESTAMP not null,
    vaild_to   timestamp
);

create table products
(
    id                integer                             not null
        constraint products_pk
            primary key,
    name              varchar                             not null,
    base_price        integer                             not null,
    product_groups_id integer
        constraint products_product_groups__fk
            references product_groups (id),
    vaild_from        timestamp default CURRENT_TIMESTAMP not null,
    vaild_to          timestamp
);

create table policies
(
    id          integer
        constraint policies_pk
            primary key,
    customer_id integer                             not null
        constraint policies_customer_null_fk
            references customer (id),
    product_id  integer                             not null
        constraint policies_product_null_fk
            references products (id),
    discount    integer                             not null,
    vaild_from  timestamp default CURRENT_TIMESTAMP not null,
    vaild_to    timestamp
);

create table mediations
(
    id         integer                             not null
        constraint mediations_pk
            primary key,
    policy_id  integer                             not null
        constraint mediations_policies__fk
            references policies (id),
    agent_id   integer                             not null
        constraint mediations_agents_null_fk
            references agents (id),
    vaild_from timestamp default CURRENT_TIMESTAMP not null,
    vaild_to   timestamp
);

create table favors
(
    id       integer
        constraint favors_pk
            primary key,
    policy   integer,
    customer integer
        constraint favors_customer_null_fk
            references customer (id)
        constraint favors_policies_null_fk
            references policies (id)
);

-- VIEWS
create view star_revenue as (
    select pg.id as "ProduktGruppeID",
        c.id as "KundenID",
        p.id as "ProduktID",
        a.id as "MarklerID",
        sum(a.commission + (p.base_price * policies.discount)) as "Umsatz",
        DATE(policies.vaild_to) as "Tag"
    FROM policies
    INNER JOIN customer c on c.id = policies.customer_id
    INNER JOIN products p on p.id = policies.product_id
    INNER JOIN product_groups pg on pg.id = p.product_groups_id
    INNER JOIN mediations m on policies.id = m.policy_id
    INNER JOIN agents a on m.agent_id = a.id

    GROUP BY pg.id, c.id, p.id, a.id, DATE(policies.vaild_to)
); --TODO check if that makes sense

create view snow_revenue as (
    select policies.id as "PoliceID",
        sum(a.commission + (p.base_price * policies.discount)) as "Umsatz",
        DATE(policies.vaild_to) as "Tag"
    FROM policies
    INNER JOIN customer c on c.id = policies.customer_id
    INNER JOIN products p on p.id = policies.product_id
    INNER JOIN product_groups pg on pg.id = p.product_groups_id
    INNER JOIN mediations m on policies.id = m.policy_id
    INNER JOIN agents a on m.agent_id = a.id

    GROUP BY policies.id, DATE(policies.vaild_to)
); --TODO prob. switch to agent/ group or product
