CREATE TABLE IF NOT EXISTS customer (
    customer_id      SERIAL PRIMARY KEY,
    first_name       VARCHAR(100) NOT NULL,
    last_name        VARCHAR(100) NOT NULL,
    email            VARCHAR(100) NOT NULL UNIQUE,
    password         VARCHAR(255) NOT NULL,
    address          VARCHAR(100),
    phone_number     VARCHAR(20),
    created_at       TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS uk_customer_email_ci ON customer (LOWER(email));

CREATE TABLE IF NOT EXISTS category (
    category_id      SERIAL PRIMARY KEY,
    name             VARCHAR(100) NOT NULL UNIQUE,
    created_at       TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS product (
    product_id       SERIAL PRIMARY KEY,
    sku              VARCHAR(100) NOT NULL UNIQUE,
    description      VARCHAR(100),
    price            DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    stock            INTEGER NOT NULL DEFAULT 0 CHECK (stock >= 0),
    category_id      INTEGER NOT NULL REFERENCES category(category_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    created_at       TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS payment (
    payment_id       SERIAL PRIMARY KEY,
    payment_date     TIMESTAMP NOT NULL DEFAULT NOW(),  -- business timestamp
    payment_method   VARCHAR(100) NOT NULL,
    amount           DECIMAL(10,2) NOT NULL CHECK (amount >= 0),
    customer_id      INTEGER NOT NULL REFERENCES customer(customer_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    created_at       TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS shipment (
    shipment_id      SERIAL PRIMARY KEY,
    shipment_date    TIMESTAMP NOT NULL DEFAULT NOW(),  -- business timestamp
    address          VARCHAR(100) NOT NULL,
    city             VARCHAR(100) NOT NULL,
    state            VARCHAR(20),
    country          VARCHAR(50) NOT NULL,
    zip_code         VARCHAR(10),
    customer_id      INTEGER NOT NULL REFERENCES customer(customer_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    created_at       TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "order" (
    order_id         SERIAL PRIMARY KEY,
    order_date       TIMESTAMP NOT NULL DEFAULT NOW(),  -- business timestamp
    total_price      DECIMAL(10,2) NOT NULL CHECK (total_price >= 0),
    customer_id      INTEGER NOT NULL REFERENCES customer(customer_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    payment_id       INTEGER     REFERENCES payment(payment_id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    shipment_id      INTEGER     REFERENCES shipment(shipment_id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    created_at       TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS order_item (
    order_item_id    SERIAL PRIMARY KEY,
    order_id         INTEGER NOT NULL REFERENCES "order"(order_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    product_id       INTEGER NOT NULL REFERENCES product(product_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    quantity         INTEGER NOT NULL CHECK (quantity > 0),
    price            DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    CONSTRAINT uq_order_item UNIQUE (order_id, product_id),
    created_at       TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS cart (
    cart_id          SERIAL PRIMARY KEY,
    customer_id      INTEGER NOT NULL REFERENCES customer(customer_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    product_id       INTEGER NOT NULL REFERENCES product(product_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    quantity         INTEGER NOT NULL CHECK (quantity > 0),
    CONSTRAINT uq_cart UNIQUE (customer_id, product_id),
    created_at       TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS wishlist (
    wishlist_id      SERIAL PRIMARY KEY,
    customer_id      INTEGER NOT NULL REFERENCES customer(customer_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    product_id       INTEGER NOT NULL REFERENCES product(product_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT uq_wishlist UNIQUE (customer_id, product_id),
    created_at       TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_product_category_id   ON product(category_id);
CREATE INDEX IF NOT EXISTS idx_payment_customer_id   ON payment(customer_id);
CREATE INDEX IF NOT EXISTS idx_shipment_customer_id  ON shipment(customer_id);
CREATE INDEX IF NOT EXISTS idx_order_customer_id     ON "order"(customer_id);
CREATE INDEX IF NOT EXISTS idx_order_payment_id      ON "order"(payment_id);
CREATE INDEX IF NOT EXISTS idx_order_shipment_id     ON "order"(shipment_id);
CREATE INDEX IF NOT EXISTS idx_order_item_order_id   ON order_item(order_id);
CREATE INDEX IF NOT EXISTS idx_order_item_product_id ON order_item(product_id);
CREATE INDEX IF NOT EXISTS idx_cart_customer_id      ON cart(customer_id);
CREATE INDEX IF NOT EXISTS idx_cart_product_id       ON cart(product_id);
CREATE INDEX IF NOT EXISTS idx_wishlist_customer_id  ON wishlist(customer_id);
CREATE INDEX IF NOT EXISTS idx_wishlist_product_id   ON wishlist(product_id);
